ScriptName DAC:Quest:PlayerLocationChangeHandler Extends ReferenceAlias

Quest Property DAC_Quest Auto
RefCollectionAlias Property FindNPCs Auto
GlobalVariable Property DAC_UpdateGlobal Auto ; Required global variable for alias update

Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    Debug.Trace("DAC: Entered ship. Updating alias.")
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for the alias to update
    (DAC_Quest as DAC:Quest:DisableActorCollisionOnPlayerShip).DisableCollisionForShipNPCs()
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    Debug.Trace("DAC: Exited ship. Updating alias.")
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for the alias to update
    (DAC_Quest as DAC:Quest:DisableActorCollisionOnPlayerShip).EnableCollisionForAllNPCs()
EndEvent

Function UpdateFinderAlias()
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs alias is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FindNPCs RefCollectionAlias.")
    ; Remove all NPCs from the alias
    While FindNPCs.GetCount() > 0
        FindNPCs.RemoveAll()
    EndWhile
    ; Ensure a valid global variable is set for the update function
    If DAC_UpdateGlobal == None
        Debug.Notification("DAC: ERROR - DAC_UpdateGlobal is not set!")
        Return
    EndIf
    ; Toggle the global variable between 0 and 1
    Float currentValue = DAC_UpdateGlobal.GetValue()
    Debug.Trace("DAC: Current value of DAC_UpdateGlobal: " + currentValue)
    DAC_UpdateGlobal.SetValue(1.0 - currentValue)
    Debug.Trace("DAC: New value of DAC_UpdateGlobal: " + DAC_UpdateGlobal.GetValue())
    ; Trigger alias update
    Self.GetOwningQuest().UpdateCurrentInstanceGlobal(DAC_UpdateGlobal)
    Int foundCount = FindNPCs.GetCount()
    Debug.Notification("DAC: Finder NPC Collection updated. " + foundCount + " NPCs in alias.")
EndFunction
