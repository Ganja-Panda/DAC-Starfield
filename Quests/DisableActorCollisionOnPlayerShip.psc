;======================================================================
; SCRIPT: DisableActorCollisionOnPlayerShip
; AUTHOR: Ganja Panda Creations
; TITLE: Disable Actor Collision on Player Ship
; DESCRIPTION: 
;    - Handles collision toggling for crew members aboard the player’s ship.
;    - Uses event-driven approach instead of polling.
;    - Listens for a custom event fired by PlayerLocationChangeHandler.
;
;======================================================================

ScriptName DAC:Quests:DisableActorCollisionOnPlayerShip Extends RefCollectionAlias

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================
GlobalVariable Property DAC_UpdateGlobal Auto
LocationAlias Property playerShipInterior Auto Const Mandatory

; Reference to the PlayerLocationChangeHandler instance
DAC:Quests:PlayerLocationChangeHandler Property PlayerLocationHandler Auto Const Mandatory

;======================================================================
; INITIALIZATION
;======================================================================
Event OnInit()
    Debug.Notification("DAC: DisableActorCollisionOnPlayerShip initializing...")

    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile
    Utility.Wait(2.0)

    If Self.GetCount() == 0
        Debug.Notification("DAC ERROR: Alias Collection is empty!")
        Return
    EndIf

    Int retries = 5
    While retries > 0 && PlayerLocationHandler == None
        Utility.Wait(1.0)
        retries -= 1
    EndWhile

    If PlayerLocationHandler
        RegisterForCustomEvent(PlayerLocationHandler, "DAC_PlayerLocationChanged")
        Debug.Notification("DAC: Registered for player location change event.")
    Else
        Debug.Notification("DAC ERROR: PlayerLocationHandler reference is STILL None after retries!")
    EndIf
EndEvent


;======================================================================
; EVENT: Handle Custom Event from PlayerLocationChangeHandler
;======================================================================
Event DAC:Quests:PlayerLocationChangeHandler.DAC_PlayerLocationChanged(DAC:Quests:PlayerLocationChangeHandler akSender, Var[] akArgs)
    Bool bPlayerOnShip = akArgs[0] as Bool
    UpdateCollisionStates(bPlayerOnShip)
EndEvent

;======================================================================
; FUNCTION: Update Collision States
;======================================================================
Function UpdateCollisionStates(Bool bPlayerOnShip)
    Actor PlayerRef = Game.GetPlayer()
    Int count = Self.GetCount()
    Debug.Notification("DAC: Updating collision for " + count + " NPCs.")

    Int j = 0
    While j < count
        Actor CrewMember = Self.GetAt(j) as Actor
        If CrewMember && CrewMember.Is3DLoaded()
            If !bPlayerOnShip
                EnableCollision(CrewMember)
            Else
                DisableCollision(CrewMember)
            EndIf
        Else
            Debug.Notification("DAC WARNING: CrewMember at index " + j + " is None or not loaded!")
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
        Debug.Notification("DAC: Enabled collision for " + akActor)
    EndIf
EndFunction