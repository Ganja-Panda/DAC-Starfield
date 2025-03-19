;======================================================================
; SCRIPT: PlayerLocationChangeHandler
; AUTHOR: Ganja Panda Creations
; TITLE: Handle Player Location Changes
; DESCRIPTION: 
;    - Tracks player location changes.
;    - Fires an event when entering or exiting the ship.
;
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends ReferenceAlias

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================
GlobalVariable Property DAC_UpdateGlobal Auto
Bool Property IsOccupantListUpdated = False Auto

; Explicitly declare the custom event
CustomEvent DAC_PlayerLocationChanged

;======================================================================
; EVENT HANDLERS
;======================================================================
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship. Notifying collision handler.")
    FireLocationChangeEvent(True)
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship. Notifying collision handler.")
    FireLocationChangeEvent(False)
EndEvent

;======================================================================
; FUNCTION: Fire Custom Event
;======================================================================
Function FireLocationChangeEvent(Bool bPlayerOnShip)
    Var[] args = new Var[1]
    args[0] = bPlayerOnShip
    SendCustomEvent("DAC_PlayerLocationChanged", args)
EndFunction