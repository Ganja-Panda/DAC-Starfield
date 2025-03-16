;======================================================================
; Script: DAC:Quests:PlayerLocationChangeHandler
; Description: Handles player location changes for ship interiors.
;              Updates the ReferenceAlias and triggers collision
;              updates in the main collision alias.
;======================================================================

ScriptName DAC:Quests:PlayerLocationChangeHandler Extends ReferenceAlias

;----------------------------
; Property Definitions
;----------------------------
DAC:Quests:DisableActorCollisionOnPlayerShip Property DAC_CollisionAlias Auto
GlobalVariable Property DAC_UpdateGlobal Auto ; Required global variable for alias update

;----------------------------
; Event Handlers
;----------------------------
Event OnEnterShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Entered ship. Updating alias.")

    UpdateFinderAlias()
    Utility.Wait(2.0) ; Ensure alias updates before applying collision changes

    If DAC_CollisionAlias
        Actor PlayerRef = Self.GetActorReference()  ; Ensure we get the player
        If PlayerRef
            Debug.Notification("DAC: Disabling player collision.")
            DAC_CollisionAlias.DisableCollision(PlayerRef)
        Else
            Debug.Notification("DAC ERROR: Player Reference is invalid.")
        EndIf
    EndIf
EndEvent

Event OnExitShipInterior(ObjectReference akShip)
    Debug.Notification("DAC: Exited ship. Updating alias.")

    UpdateFinderAlias()
    Utility.Wait(2.0) ; Ensure alias updates before applying collision changes

    If DAC_CollisionAlias
        Actor PlayerRef = Self.GetActorReference()  ; Ensure we get the player
        If PlayerRef
            Debug.Notification("DAC: Enabling player collision.")
            DAC_CollisionAlias.EnableCollision(PlayerRef)
        Else
            Debug.Notification("DAC ERROR: Player Reference is invalid.")
        EndIf
    EndIf
EndEvent

;----------------------------
; UpdateFinderAlias Function
;----------------------------
Function UpdateFinderAlias()
    ; Ensure the alias is valid.
    Actor PlayerRef = Self.GetActorReference()
    If PlayerRef == None
        Debug.Notification("DAC ERROR: Player Reference Alias is None.")
        Return
    EndIf
    Debug.Notification("DAC: Updating Player Reference Alias.")

    ; Ensure the global variable is valid.
    If DAC_UpdateGlobal == None
        Debug.Notification("DAC ERROR: DAC_UpdateGlobal is not set.")
        Return
    EndIf

    ; Toggle the global variable between 0 and 1.
    Float currentValue = DAC_UpdateGlobal.GetValue()
    Debug.Notification("DAC: Current DAC_UpdateGlobal: " + currentValue)
    DAC_UpdateGlobal.SetValue(1.0 - currentValue)
    Debug.Notification("DAC: New DAC_UpdateGlobal: " + DAC_UpdateGlobal.GetValue())

    ; Trigger alias update via the owning quest.
    Self.GetOwningQuest().UpdateCurrentInstanceGlobal(DAC_UpdateGlobal)

    Debug.Notification("DAC: Player Reference Alias updated.")
EndFunction
