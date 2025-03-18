;======================================================================
; SCRIPT: DisableActorCollisionOnPlayerShip
; AUTHOR: Ganja Panda Creations
; TITLE: Disable Actor Collision on Player Ship
; DESCRIPTION: 
;    - Handles collision toggling for crew members aboard the player's ship.
;    - Disables collision when the player is inside the ship.
;    - Re-enables collision when the player leaves the ship.
;    - Uses CassiopeiaPapyrusExtender for collision management.
;
;======================================================================

ScriptName DAC:Quests:DisableActorCollisionOnPlayerShip Extends RefCollectionAlias

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================
GlobalVariable Property DAC_UpdateGlobal Auto  ; Required global variable for alias update
LocationAlias Property playerShipInterior Auto Const mandatory        ; Alias for the player's ship interior location

;======================================================================
; INITIALIZATION
;======================================================================
Event OnInit()
    Debug.Notification("DAC: DisableActorCollisionOnPlayerShip initializing...")
    
    Debug.Notification("DAC: Waiting for player 3D load...")
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile
    
    Utility.Wait(2.0)  ; Ensure all actors are fully loaded

    If Self.GetCount() == 0
        Debug.Notification("DAC ERROR: Alias Collection is empty!")
        Return
    EndIf

    Debug.Notification("DAC: Initialization complete. Monitoring collision changes.")
    StartMonitoringGlobal()
EndEvent

;======================================================================
; FUNCTION: Poll DAC_UpdateGlobal
;======================================================================
Function StartMonitoringGlobal()
    Float lastValue = DAC_UpdateGlobal.GetValue()
    
    ; Infinite loop that checks for updates until script is reset/unloaded
    While True
        Float currentValue = DAC_UpdateGlobal.GetValue()
        If currentValue != lastValue
            Debug.Notification("DAC: Global changed, updating collision states.")
            UpdateCollisionStates()
            lastValue = currentValue
        EndIf
        Utility.Wait(1.0)  ; Adjust polling interval as needed
    EndWhile
EndFunction

;======================================================================
; FUNCTION: Update Collision States
;======================================================================
Function UpdateCollisionStates()
    Actor PlayerRef = Game.GetPlayer()
    Bool bPlayerOnShip = PlayerRef.IsInLocation(playerShipInterior.GetLocation())

    Int count = Self.GetCount()
    Debug.Notification("DAC: Updating collision for " + count + " NPCs.")

    ; Only process actors who are currently 3D loaded (meaning they are with the player)
    Int j = 0
    While j < count
        Actor CrewMember = Self.GetAt(j) as Actor
        If CrewMember && CrewMember.Is3DLoaded()
            If !bPlayerOnShip
                Debug.Notification("DAC: Actor " + CrewMember + " left the ship with player.")
                EnableCollision(CrewMember)
            ;Else
            ;    If !CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
            ;        DisableCollision(CrewMember)
            ;    EndIf
            EndIf
        Else
            Debug.Notification("DAC: Ignoring actor " + CrewMember + " (Not 3D loaded, still on ship)")
        EndIf
        j += 1
    EndWhile
EndFunction


;======================================================================
; FUNCTION: Disable Collision
;======================================================================
Function DisableCollision(Actor akActor)
    If akActor
        CassiopeiaPapyrusExtender.DisableCollision(akActor, true)
        CassiopeiaPapyrusExtender.UpdateReference3D(akActor)
        ;CassiopeiaPapyrusExtender.InitHavok(akActor) ; will be used in Cassiopeia 3.0
        ;CassiopeiaPapyrusExtender.Set3DUpdateFlag(akActor, 256)  ; Havok flag
        ;CassiopeiaPapyrusExtender.ClampToGround(akActor)
        Debug.Notification("DAC: Disabled collision for " + akActor)
    EndIf
EndFunction

;======================================================================
; FUNCTION: Enable Collision
;======================================================================
Function EnableCollision(Actor akActor)
    If akActor
        CassiopeiaPapyrusExtender.DisableCollision(akActor, false)
        CassiopeiaPapyrusExtender.UpdateReference3D(akActor)
        ;CassiopeiaPapyrusExtender.InitHavok(akActor)
        ;CassiopeiaPapyrusExtender.Set3DUpdateFlag(akActor, 256)  ; Havok flag
        ;CassiopeiaPapyrusExtender.ClampToGround(akActor)
        Debug.Notification("DAC: Enabled collision for " + akActor)
    EndIf
EndFunction