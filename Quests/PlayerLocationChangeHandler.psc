;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: This script handles player location changes for ship interiors.
;              It updates the RefCollectionAlias (FindNPCs) and then triggers
;              collision updates in the main collision quest.
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends Quest

;----------------------------
; Property Definitions
;----------------------------
; DAC_Quest:
;   - Type: Quest
;   - Purpose: The main quest that controls collision handling.
Quest Property DAC_Quest Auto

; FindNPCs:
;   - Type: RefCollectionAlias
;   - Purpose: Holds a collection of NPC references that need collision updates.
RefCollectionAlias Property FindNPCs Auto

; DAC_UpdateGlobal:
;   - Type: GlobalVariable
;   - Purpose: Global variable used to trigger alias updates.
GlobalVariable Property DAC_UpdateGlobal Auto

;----------------------------
; Event Handlers
;----------------------------
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    Debug.Trace("DAC: Entered ship. Updating alias.")
    
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for alias update to complete
    
    ; Call collision update on the main collision quest.
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).DisableCollisionForShipNPCs()
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    Debug.Trace("DAC: Exited ship. Updating alias.")
    
    UpdateFinderAlias()
    Utility.Wait(1.0) ; Wait for alias update to complete
    
    ; Call collision update on the main collision quest.
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).EnableCollisionForAllNPCs()
EndEvent

;----------------------------
; Function Definitions
;----------------------------
Function UpdateFinderAlias()
    ; Ensure the FindNPCs alias is assigned.
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs alias is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FindNPCs RefCollectionAlias.")

    ; Remove all entries from the alias.
    While FindNPCs.GetCount() > 0
        FindNPCs.RemoveAll()
    EndWhile

    ; Check that the global variable is assigned.
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
    Quest owningQuest = Self.GetOwningQuest()
    If owningQuest != None
        owningQuest.UpdateCurrentInstanceGlobal(DAC_UpdateGlobal)
    Else
        Debug.Notification("DAC: ERROR - Owning quest is not available!")
    EndIf

    ; Report the updated count.
    Int foundCount = FindNPCs.GetCount()
    Debug.Notification("DAC: Finder NPC Collection updated. " + foundCount + " NPCs in alias.")
EndFunction
