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
Faction Property CrewFaction Auto  ; Faction that determines crew membership
Keyword Property COM_CompanionKeyword Auto  ; Keyword to identify companions

;======================================================================
; INITIALIZATION
;======================================================================
Event OnInit()
    Debug.Notification("DAC: DisableActorCollisionOnPlayerShip initializing...")
    
    Debug.Notification("DAC: Waiting for player 3D load...")
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile
    
    Utility.Wait(3.0)  ; Ensure all actors are fully loaded

    If Self.GetCount() == 0
        Debug.Notification("DAC ERROR: Alias Collection is empty!")
        Return
    EndIf

    Debug.Notification("DAC: Initialization complete. Monitoring collision changes.")
    StartMonitoringGlobal()  ; Start checking DAC_UpdateGlobal
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
    Bool bPlayerOnShip = PlayerRef.IsInInterior()  ; Example check, replace with ship-specific condition

    Int count = Self.GetCount()
    Debug.Notification("DAC: Updating collision for " + count + " NPCs.")

    ; Ensure only followers are 3D loaded, skip others
    Int i = 0
    While i < count
        Actor CrewMember = Self.GetAt(i) as Actor
        If CrewMember
            If CrewMember.IsInFaction(CrewFaction)  ; Replace 'CrewFaction' with the correct faction
                Int waitTime = 0
                While !CrewMember.Is3DLoaded() && waitTime < 10
                    Utility.Wait(1.0)
                    waitTime += 1
                EndWhile
            EndIf
        EndIf
        i += 1
    EndWhile

    ; Compare actors leaving the ship with CompanionActorScript
    Int j = 0
    While j < count
        Actor CrewMember = Self.GetAt(j) as Actor
        If CrewMember
            If !bPlayerOnShip
                Float companionID = (CrewMember as CompanionActorScript).GetCompanionIDValue()
                If CrewMember.HasKeyword(COM_CompanionKeyword) || (CrewMember as CompanionActorScript).GetCompanionIDValue() == companionID
                    Debug.Notification("DAC: Companion " + CrewMember + " left the ship with player.")
                    EnableCollision(CrewMember)
                Else
                    Debug.Notification("DAC: Crew member " + CrewMember + " remains on ship.")
                EndIf
            Else
                If !CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
                    DisableCollision(CrewMember)
                EndIf
            EndIf
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
        CassiopeiaPapyrusExtender.InitHavok(akActor)
        CassiopeiaPapyrusExtender.Set3DUpdateFlag(akActor, 256)  ; Havok flag
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
        CassiopeiaPapyrusExtender.InitHavok(akActor)
        CassiopeiaPapyrusExtender.Set3DUpdateFlag(akActor, 256)  ; Havok flag
        ;CassiopeiaPapyrusExtender.ClampToGround(akActor)
        Debug.Notification("DAC: Enabled collision for " + akActor)
    EndIf
EndFunction