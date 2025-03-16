;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: Handles player location changes for ship interiors.
;              Updates the FormList (FL_DAC_ShipCrew) and triggers collision
;              updates in the main collision quest.
;              Must be attached to a player's reference alias.
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends ReferenceAlias

;----------------------------
; Property Definitions
;----------------------------
Quest Property DAC_Quest Auto
FormList Property FL_DAC_ShipCrew Auto
GlobalVariable Property DAC_UpdateGlobal Auto

;----------------------------
; Handler Functions
;----------------------------
Function HandleEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship: " + akShip)
    
    ; Check if the player is on the ship.
    Bool onShip = CassiopeiaPapyrusExtender.IsOnPlayerHomeSpaceship(Game.GetPlayer())
    If !onShip
        Debug.Notification("DAC: Player is not on the ship. Ignoring enter event.")
        Return
    EndIf
    
    Debug.Trace("DAC: Player is on ship. Updating FormList.")
    UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for update to complete
    
    If DAC_Quest != None
        (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).DisableCollisionForShipNPCs()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf
EndFunction

Function HandleExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship: " + akShip)
    
    ; Check if the player is still on the ship.
    Bool onShip = CassiopeiaPapyrusExtender.IsOnPlayerHomeSpaceship(Game.GetPlayer())
    If onShip
        Debug.Notification("DAC: Player is still on the ship. Ignoring exit event.")
        Return
    EndIf
    
    Debug.Trace("DAC: Player is off ship. Updating FormList.")
    UpdateFinderFormList()
    Utility.Wait(1.0) ; Wait for update to complete
    
    If DAC_Quest != None
        (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).EnableCollisionForAllNPCs()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf
EndFunction

;----------------------------
; UpdateFinderFormList Function
;----------------------------
Function UpdateFinderFormList()
    If FL_DAC_ShipCrew == None
        Debug.Notification("DAC: ERROR - FL_DAC_ShipCrew FormList is None!")
        Return
    EndIf
    Debug.Trace("DAC: Updating FormList.")

    While FL_DAC_ShipCrew.GetSize() > 0
        FL_DAC_ShipCrew.RemoveAddedForm(FL_DAC_ShipCrew.GetAt(0))
    EndWhile

    If DAC_Quest != None
        (DAC_Quest as DAC:Quests:DisableActorCollisionOnPlayerShip).PopulateCrewList()
    Else
        Debug.Notification("DAC: ERROR - DAC_Quest is None!")
    EndIf

    Int foundCount = FL_DAC_ShipCrew.GetSize()
    Debug.Notification("DAC: FormList updated. " + foundCount + " NPCs in list.")
EndFunction
