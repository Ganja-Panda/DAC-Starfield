;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: Handles player location changes for ship interiors.
;              Updates the FormList (FindNPCs) and triggers collision
;              updates in the main collision quest.
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends Quest

;----------------------------
; Property Definitions
;----------------------------
Quest Property DAC_Quest Auto
FormList Property FindNPCs Auto
GlobalVariable Property DAC_UpdateGlobal Auto

;----------------------------
; Handler Functions (internal)
;----------------------------
Function HandleEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    Debug.Trace("DAC: Entered ship. Updating FormList.")
    
    self.UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for update to complete
    
    If self.DAC_Quest != None
        (self.DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).DisableCollisionForShipNPCs()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf
EndFunction

Function HandleExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    Debug.Trace("DAC: Exited ship. Updating FormList.")
    
    self.UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for update to complete
    
    If self.DAC_Quest != None
        (self.DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).EnableCollisionForAllNPCs()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf
EndFunction

;----------------------------
; UpdateFinderFormList Function
;----------------------------
Function UpdateFinderFormList()
    If self.FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FormList.")

    While self.FindNPCs.GetSize() > 0
        self.FindNPCs.RemoveAddedForm(self.FindNPCs.GetAt(0))
    EndWhile

    If self.DAC_Quest != None
        (self.DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).PopulateCrewList()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf

    Int foundCount = self.FindNPCs.GetSize()
    Debug.Notification("DAC: FormList updated. " + foundCount + " NPCs in list.")
EndFunction
