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
ReferenceAlias Property ShipInterior Auto Const Mandatory  ; Set in CK
ReferenceAlias Property ShipExterior Auto Const Mandatory  ; Set in CK

;======================================================================
; EVENT HANDLERS
;======================================================================
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    Debug.Notification("DAC: Player changed location.")
    
    Actor PlayerRef = Self.GetActorReference()
    If PlayerRef == None
        Debug.Notification("DAC ERROR: Player Reference Alias is None.")
        Return
    EndIf
    
    ; Ensure we have valid locations to compare
    Location shipInteriorLoc = ShipInterior.GetReference().GetCurrentLocation()
    Location shipExteriorLoc = ShipExterior.GetReference().GetCurrentLocation()

    If akNewLoc == shipInteriorLoc && akOldLoc == shipExteriorLoc
        Debug.Notification("DAC: Player entered the ship. Disabling collision.")
        DAC_UpdateGlobal.SetValue(1)  ; Signal collision should be disabled
        IsOccupantListUpdated = True
    ElseIf akNewLoc == shipExteriorLoc && akOldLoc == shipInteriorLoc
        Debug.Notification("DAC: Player exited the ship. Enabling collision.")
        DAC_UpdateGlobal.SetValue(0)  ; Signal collision should be enabled
        IsOccupantListUpdated = False
    Else
        Debug.Notification("DAC: Ignoring location change (Not ship-related).")
    EndIf
EndEvent