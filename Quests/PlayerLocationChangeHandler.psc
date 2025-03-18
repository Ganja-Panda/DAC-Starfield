;======================================================================
; SCRIPT: PlayerLocationChangeHandler
; AUTHOR: Ganja Panda Creations
; TITLE: Disable Actor Collision on Player Ship
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
Bool Property IsOccupantListUpdated = False Auto ; Tracks if the list is already updated

;======================================================================
; EVENT HANDLERS
;======================================================================
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Trace("DAC: Entered ship. Updating alias.")

    ; Notify DisableActorCollisionOnPlayerShip by toggling DAC_UpdateGlobal
    If DAC_UpdateGlobal
        DAC_UpdateGlobal.SetValue(1) ; Signal collision should be disabled
    EndIf

    UpdateFinderAlias()
    IsOccupantListUpdated = True
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Trace("DAC: Exited ship. Updating alias.")

    ; Notify DisableActorCollisionOnPlayerShip by toggling DAC_UpdateGlobal
    If DAC_UpdateGlobal
        DAC_UpdateGlobal.SetValue(0) ; Signal collision should be enabled
    EndIf

    UpdateFinderAlias()
    IsOccupantListUpdated = False ; Allow the list to be refreshed on the next entry
EndEvent

Function UpdateFinderAlias()
    ; Ensure the alias is valid.
    Actor PlayerRef = Self.GetActorReference()
    If PlayerRef == None
        Debug.Trace("DAC ERROR: Player Reference Alias is None.")
        Return
    EndIf
    Debug.Trace("DAC: Updating Player Reference Alias.")

    ; Directly set the alias reference instead of relying on global toggling.
    ReferenceAlias PlayerAlias = Self as ReferenceAlias
    If PlayerAlias
        PlayerAlias.ForceRefTo(PlayerRef)
        Debug.Trace("DAC: Player Reference Alias successfully updated.")
    Else
        Debug.Trace("DAC ERROR: PlayerAlias is invalid.")
    EndIf
EndFunction
