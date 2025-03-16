;======================================================================
; Script: DAC:Quests:DisableActorCollisionOnPlayerShip
; Description: This quest script dynamically populates a FormList with NPCs
;              based on specific conditions and then toggles collision for
;              these NPCs depending on whether the player is on the home ship.
;======================================================================

ScriptName DAC:Quests:DisableActorCollisionOnPlayerShip Extends Quest

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================

FormList Property FindNPCs Auto    ; Holds NPCs whose collision will be toggled
Actor Property Crew_Elite_Vasco Auto    ; Special NPC always included in collision handling
Keyword Property Crew_CrewTypeCompanion Auto    ; Marks companion-type crew NPCs
Keyword Property Crew_CrewTypeElite Auto    ; Marks elite crew NPCs
Keyword Property Crew_CrewTypeGeneric Auto    ; Marks generic crew NPCs
Keyword Property Crew_CrewTypeGeneric_NoflavorDialogue Auto    ; Marks generic crew NPCs without flavor dialogue

;======================================================================
; EVENT HANDLER
;======================================================================
Event OnInit()
    Debug.Notification("DAC: Script initializing...")
    Debug.Notification("DAC: Waiting for player 3D load...")

    ; Wait until the player is fully loaded in 3D.
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile

    Utility.Wait(3.0) ; Ensure other actors are loaded

    ; Ensure FindNPCs is assigned
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Debug.Notification("DAC: ERROR - FindNPCs FormList is not assigned in CK.")
        Return
    EndIf

    ; Populate the FormList dynamically.
    PopulateCrewList()

    Debug.Notification("DAC: Initialized. Checking collision states...")
    UpdateCollisionStates()
EndEvent

;======================================================================
; FUNCTION: PopulateCrewList
;======================================================================
Function PopulateCrewList()
    Debug.Notification("DAC: Populating crew list...")
    FindNPCs.Revert()
    

    Actor[] loadedRefs = FindNPCs.GetArray() as Actor[]
    Int total = loadedRefs.Length
    Int i = 0
    While i < total
        Actor candidate = loadedRefs[i] as Actor
        If candidate
            Debug.Notification("DAC: Evaluating candidate: " + candidate)
            
            If candidate.IsDisabled() || CassiopeiaPapyrusExtender.HasNoCollision(candidate)
                Debug.Notification("DAC: Skipping disabled or no-collision actor: " + candidate)
            Else
                Bool hasCrewKeyword = candidate.HasKeyword(Crew_CrewTypeCompanion) || candidate.HasKeyword(Crew_CrewTypeElite) || candidate.HasKeyword(Crew_CrewTypeGeneric) || candidate.HasKeyword(Crew_CrewTypeGeneric_NoflavorDialogue)
                
                If hasCrewKeyword && candidate != Game.GetPlayer() && candidate != Crew_Elite_Vasco
                    FindNPCs.AddForm(candidate)
                    Debug.Notification("DAC: Added " + candidate + " to the FormList.")
                Else
                    Debug.Notification("DAC: Candidate " + candidate + " does not meet criteria.")
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction

;======================================================================
; FUNCTION: UpdateCollisionStates
;======================================================================
Function UpdateCollisionStates()
    Actor PlayerRef = Game.GetPlayer()
    Bool bPlayerOnShip = PlayerRef.IsInInterior() ; Example check, replace with ship-specific condition

    ; Loop through NPCs in the list
    int i = 0
    while i < FindNPCs.GetSize()
        Actor CrewMember = FindNPCs.GetAt(i) as Actor
        if CrewMember
            if bPlayerOnShip
                if !CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
                    DisableCollision(CrewMember)
                EndIf
            Else
                if CassiopeiaPapyrusExtender.HasNoCollision(CrewMember)
                    EnableCollision(CrewMember)
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction

;======================================================================
; FUNCTION: DisableCollision
;======================================================================
Function DisableCollision(Actor akActor)
    If akActor
        CassiopeiaPapyrusExtender.DisableCollision(akActor, true)
        CassiopeiaPapyrusExtender.InitHavok(akActor)
        CassiopeiaPapyrusExtender.Set3DUpdateFlag(akActor, 256) ; Havok flag
        CassiopeiaPapyrusExtender.ClampToGround(akActor)
        Debug.Notification("DAC: Disabled collision for " + akActor)
    EndIf
EndFunction

;======================================================================
; FUNCTION: EnableCollision
;======================================================================
Function EnableCollision(Actor akActor)
    If akActor
        CassiopeiaPapyrusExtender.DisableCollision(akActor, false)
        CassiopeiaPapyrusExtender.InitHavok(akActor)
        CassiopeiaPapyrusExtender.ClampToGround(akActor)
        Debug.Notification("DAC: Enabled collision for " + akActor)
    EndIf
EndFunction
