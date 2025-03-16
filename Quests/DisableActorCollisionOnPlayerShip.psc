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
ActorBase Property Crew_Elite_Vasco Auto    ; Special NPC always included in collision handling
Keyword Property Crew_CrewTypeCompanion Auto    ; Marks companion-type crew NPCs
Keyword Property Crew_CrewTypeElite Auto    ; Marks elite crew NPCs
Keyword Property Crew_CrewTypeGeneric Auto    ; Marks generic crew NPCs
Keyword Property Crew_CrewTypeGeneric_NoflavorDialogue Auto    ; Marks generic crew NPCs without flavor dialogue

;======================================================================
; EVENT HANDLER
;======================================================================
Event OnInit()
    Debug.Notification("DAC: Script initializing...")
    Debug.Trace("DAC: Waiting for player 3D load...")

    ; Wait until the player is fully loaded in 3D.
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile

    Utility.Wait(3.0) ; Ensure other actors are loaded

    ; Ensure FindNPCs is assigned
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Debug.Trace("DAC: ERROR - FindNPCs FormList is not assigned in CK.")
        Return
    EndIf

    ; Populate the FormList dynamically.
    PopulateCrewList()

    Debug.Notification("DAC: Initialized. Checking collision state.")
    CheckAndToggleCollision()
EndEvent

;======================================================================
; FUNCTION: PopulateCrewList
; Description: Retrieves all currently loaded NPC references and filters
;              them based on predefined criteria before adding them to FindNPCs.
;======================================================================
Function PopulateCrewList()
    Debug.Trace("DAC: Fetching loaded references...")
    
    ; Get all currently loaded references using the Papyrus Extender.
    ObjectReference[] loadedRefs = CassiopeiaPapyrusExtender.GetLoadedReferences()
    
    If loadedRefs == None || loadedRefs.Length == 0
        Debug.Notification("DAC: ERROR - No loaded references returned!")
        Debug.Trace("DAC: ERROR - GetLoadedReferences() returned no data.")
        Return
    EndIf

    Debug.Trace("DAC: Retrieved " + loadedRefs.Length + " references.")
    
    ; Clear any existing entries in the FormList.
    While FindNPCs.GetSize() > 0
        Debug.Trace("DAC: Removing " + FindNPCs.GetAt(0))
        FindNPCs.RemoveAddedForm(FindNPCs.GetAt(0))
    EndWhile

    ; Iterate over all loaded references and filter actors based on criteria.
    Int total = loadedRefs.Length
    Int i = 0
    While i < total
        Actor candidate = loadedRefs[i] as Actor
        If candidate
            Debug.Trace("DAC: Evaluating candidate: " + candidate)
            
            If candidate.IsDisabled()
                Debug.Trace("DAC: Skipping disabled actor: " + candidate)
            Else
                Bool isSpecialActor = (candidate == Game.GetPlayer()) || (candidate.GetBaseObject() == Crew_Elite_Vasco)
                Bool hasCrewKeyword = candidate.HasKeyword(Crew_CrewTypeCompanion) || candidate.HasKeyword(Crew_CrewTypeElite) || candidate.HasKeyword(Crew_CrewTypeGeneric) || candidate.HasKeyword(Crew_CrewTypeGeneric_NoflavorDialogue)
                
                If isSpecialActor || hasCrewKeyword
                    FindNPCs.AddForm(candidate.GetBaseObject())
                    Debug.Trace("DAC: Added " + candidate + " to the FormList.")
                Else
                    Debug.Trace("DAC: Candidate " + candidate + " does not meet criteria.")
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    Debug.Trace("DAC: FormList populated. Total entries: " + FindNPCs.GetSize())
EndFunction

;======================================================================
; FUNCTION: CheckAndToggleCollision
; Description: Determines whether the player is inside their home ship
;              and toggles collision accordingly.
;======================================================================
Function CheckAndToggleCollision()
    Bool isOnShip = CassiopeiaPapyrusExtender.IsOnPlayerHomeSpaceship(Game.GetPlayer())
    If isOnShip
        Debug.Trace("DAC: Player is on the home spaceship.")
        DisableCollisionForShipNPCs()
    Else
        Debug.Trace("DAC: Player is off the home spaceship.")
        EnableCollisionForAllNPCs()
    EndIf
EndFunction

;======================================================================
; FUNCTION: DisableCollisionForShipNPCs
; Description: Disables collision for all NPCs currently on the ship.
;======================================================================
Function DisableCollisionForShipNPCs()
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Debug.Trace("DAC: ERROR - Collision operation aborted due to missing FormList.")
        Return
    EndIf

    Int foundCount = FindNPCs.GetSize()
    Debug.Trace("DAC: Disabling collision for " + foundCount + " NPCs inside the ship.")
    
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            If !CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Trace("DAC: Setting no collision for " + targetActor)
                CassiopeiaPapyrusExtender.SetNoCollision(targetActor, True)
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction

;======================================================================
; FUNCTION: EnableCollisionForAllNPCs
; Description: Re-enables collision for all NPCs when the player leaves the ship.
;======================================================================
Function EnableCollisionForAllNPCs()
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Debug.Trace("DAC: ERROR - Collision operation aborted due to missing FormList.")
        Return
    EndIf

    Int foundCount = FindNPCs.GetSize()
    Debug.Trace("DAC: Enabling collision for " + foundCount + " NPCs.")
    
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Trace("DAC: Re-enabling collision for " + targetActor)
                CassiopeiaPapyrusExtender.SetNoCollision(targetActor, False)
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction
