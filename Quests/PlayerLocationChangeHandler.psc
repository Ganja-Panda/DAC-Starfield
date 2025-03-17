;======================================================================
; SCRIPT: PlayerLocationChangeHandler
; AUTHOR: [Your Name or Mod Name]
; DESCRIPTION: 
;    - Tracks player location changes related to ship interiors.
;    - Updates ReferenceAlias when entering and exiting the ship.
;    - Identifies which actors leave the ship with the player.
;
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends ReferenceAlias

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================
GlobalVariable Property DAC_UpdateGlobal Auto ; Required global variable for alias update
ReferenceAlias[] Property ShipOccupants Auto ; List of actors currently inside the ship
Bool Property IsOccupantListUpdated = False Auto ; Tracks if the list is already updated

;======================================================================
; EVENT HANDLERS
;======================================================================
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship. Updating alias.")

    ; Notify DisableActorCollisionOnPlayerShip by toggling DAC_UpdateGlobal
    If DAC_UpdateGlobal
        DAC_UpdateGlobal.SetValue(1) ; Signal collision should be disabled
    EndIf

    UpdateFinderAlias()
    If !IsOccupantListUpdated
        TrackShipOccupants()
        IsOccupantListUpdated = True
    EndIf
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship. Updating alias.")

    ; Notify DisableActorCollisionOnPlayerShip by toggling DAC_UpdateGlobal
    If DAC_UpdateGlobal
        DAC_UpdateGlobal.SetValue(0) ; Signal collision should be enabled
    EndIf

    UpdateFinderAlias()
    IdentifyExitingActors()
    IsOccupantListUpdated = False ; Allow the list to be refreshed on the next entry
EndEvent

Function UpdateFinderAlias()
    ; Ensure the alias is valid.
    Actor PlayerRef = Self.GetActorReference()
    If PlayerRef == None
        Debug.Notification("DAC ERROR: Player Reference Alias is None.")
        Return
    EndIf
    Debug.Notification("DAC: Updating Player Reference Alias.")

    ; Directly set the alias reference instead of relying on global toggling.
    ReferenceAlias PlayerAlias = Self as ReferenceAlias
    If PlayerAlias
        PlayerAlias.ForceRefTo(PlayerRef)
        Debug.Notification("DAC: Player Reference Alias successfully updated.")
    Else
        Debug.Notification("DAC ERROR: PlayerAlias is invalid.")
    EndIf
EndFunction

Function TrackShipOccupants()
    Debug.Notification("DAC: Tracking actors inside the ship.")
    ; Store actors inside the ship in ShipOccupants array if not already updated.
    ShipOccupants.Clear()
    Quest owningQuest = Self.GetOwningQuest()
    If owningQuest
        Int aliasCount = 0 ; Placeholder as GetNumAliases() is not a valid function
        Int i = 0
        While i < aliasCount
            ReferenceAlias aliasRef = None ; Placeholder as GetAlias() is not a valid function as ReferenceAlias
            If aliasRef
                Actor occupant = aliasRef.GetActorReference()
                If occupant
                    ShipOccupants.Add(aliasRef)
                    Debug.Notification("DAC: Added occupant ID " + occupant.GetFormID())
                EndIf
            EndIf
            i += 1
        EndWhile
    EndIf
EndFunction

Function IdentifyExitingActors()
    Debug.Notification("DAC: Identifying actors who left the ship.")
    Int i = 0
    While i < ShipOccupants.Length
        Actor occupant = ShipOccupants[i].GetActorReference()
        If occupant && !occupant.IsInInterior()
            Debug.Notification("DAC: Actor left ship with ID " + occupant.GetFormID())
            ; Re-initialize physics if necessary
            CassiopeiaPapyrusExtender.InitHavok(occupant, True)
        EndIf
        i += 1
    EndWhile
EndFunction
