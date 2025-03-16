;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: Handles player location changes for ship interiors.
;              Updates the FormList (FindNPCs) and triggers collision
;              updates in the main collision quest.
;              Must be attached to a player's reference alias.
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends ReferenceAlias

;----------------------------
; Property Definitions
;----------------------------
Quest Property DAC_Quest Auto
FormList Property FindNPCs Auto
GlobalVariable Property DAC_UpdateGlobal Auto ; Required global variable for alias update

;----------------------------
; Event Handlers
;----------------------------
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    Debug.Trace("DAC: Entered ship. Updating alias.")
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for the alias to update
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).DisableCollision()
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    Debug.Trace("DAC: Exited ship. Updating alias.")
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for the alias to update
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).EnableCollision()
EndEvent

;----------------------------
; UpdateFinderAlias Function
;----------------------------
Function UpdateFinderAlias()
    ; Check that the FormList is valid.
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs alias is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FindNPCs FormList.")

    ; Remove all NPCs from the FormList.
    While FindNPCs.GetSize() > 0
        FindNPCs.RemoveAddedForm(FindNPCs.GetAt(0))
    EndWhile

    ; Check that the global variable is valid.
    If DAC_UpdateGlobal == None
        Debug.Notification("DAC: ERROR - DAC_UpdateGlobal is not set!")
        Return
    EndIf

    ; Toggle the global variable between 0 and 1.
    Float currentValue = DAC_UpdateGlobal.GetValue()
    Debug.Trace("DAC: Current value of DAC_UpdateGlobal: " + currentValue)
    DAC_UpdateGlobal.SetValue(1.0 - currentValue)
    Debug.Trace("DAC: New value of DAC_UpdateGlobal: " + DAC_UpdateGlobal.GetValue())

    ; Trigger alias update via the owning quest.
    Self.GetOwningQuest().UpdateCurrentInstanceGlobal(DAC_UpdateGlobal)

    ; Report the updated count.
    Int foundCount = FindNPCs.GetSize()
    Debug.Notification("DAC: Finder NPC Collection updated. " + foundCount + " NPCs in alias.")
EndFunction
