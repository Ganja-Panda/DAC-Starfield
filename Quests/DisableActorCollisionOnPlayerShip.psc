;======================================================================
; SCRIPT: DisableActorCollisionOnPlayerShip
; AUTHOR: [Your Name or Mod Name]
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

    ; Ensure all actors are 3D loaded
    Bool allLoaded = False
    While !allLoaded
        allLoaded = True
        Int i = 0
        While i < count
            Actor CrewMember = Self.GetAt(i) as Actor
            If CrewMember && !CrewMember.Is3DLoaded()
                allLoaded = False
                Debug.Notification("DAC: Waiting for all crew members to be 3D loaded.")
                Utility.Wait(1.0)
            EndIf
            i += 1
        EndWhile
    EndWhile

    ; Proceed with updating collision states
    Int j = 0
    While j < count
        Actor CrewMember = Self.GetAt(j) as Actor
        If CrewMember
            If bPlayerOnShip
                If !CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
                    DisableCollision(CrewMember)
                EndIf
            Else
                If CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
                    EnableCollision(CrewMember)
                EndIf
            EndIf
        Else
            Debug.Notification("DAC ERROR: Alias at index [" + j + "] is empty!")
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