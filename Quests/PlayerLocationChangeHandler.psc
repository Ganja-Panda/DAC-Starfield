;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: This script handles player location changes for ship interiors.
;              It updates the FormList (FindNPCs) and then triggers collision
;              updates in the main collision quest.
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
;   - Type: FormList
;   - Purpose: Holds a collection of NPC base forms for collision updates.
FormList Property FindNPCs Auto

; DAC_UpdateGlobal:
;   - Type: GlobalVariable
;   - Purpose: Global variable used to trigger alias updates (if needed).
GlobalVariable Property DAC_UpdateGlobal Auto

;----------------------------
; Event Handlers
;----------------------------
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    Debug.Trace("DAC: Entered ship. Updating FormList.")
    
    UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for the update to complete
    
    ; Call collision update on the main collision quest.
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).DisableCollisionForShipNPCs()
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    Debug.Trace("DAC: Exited ship. Updating FormList.")
    
    UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for the update to complete
    
    ; Call collision update on the main collision quest.
    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).EnableCollisionForAllNPCs()
EndEvent

;----------------------------
; Function Definitions
;----------------------------
Function UpdateFinderFormList()
    ; Ensure the FormList property is valid.
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FormList.")

    ; Clear all entries from the FormList.
    While FindNPCs.GetSize() > 0
        FindNPCs.RemoveAddedForm(FindNPCs.GetAt(0))
    EndWhile

    (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).PopulateCrewList()

    ; Report the updated count.
    Int foundCount = FindNPCs.GetSize()
    Debug.Notification("DAC: FormList updated. " + foundCount + " NPCs in list.")
EndFunction
