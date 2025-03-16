;======================================================================
; Script: DAC:Quests:DisableActorCollisionOnPlayerShip
; Description: This quest script dynamically populates a FormList with NPCs
;              based on specific conditions and then toggles collision for
;              these NPCs depending on whether the player is on the home ship.
;======================================================================

ScriptName DAC:Quests:DisableActorCollisionOnPlayerShip Extends Quest

;----------------------------
; Property Definitions
;----------------------------
; FindNPCs:
;   - Type: FormList
;   - Purpose: Holds NPC base forms for collision handling.
FormList Property FindNPCs Auto

; Crew_Elite_Vasco:
;   - Type: ActorBase
;   - Purpose: Special NPC always included in checks.
ActorBase Property Crew_Elite_Vasco Auto

; Crew_CrewTypeCompanion:
;   - Type: Keyword
;   - Purpose: Marks companion-type crew NPCs.
Keyword Property Crew_CrewTypeCompanion Auto

; Crew_CrewTypeElite:
;   - Type: Keyword
;   - Purpose: Marks elite crew NPCs.
Keyword Property Crew_CrewTypeElite Auto

; Crew_CrewTypeGeneric:
;   - Type: Keyword
;   - Purpose: Marks generic crew NPCs.
Keyword Property Crew_CrewTypeGeneric Auto

; Crew_CrewTypeGeneric_NoflavorDialogue:
;   - Type: Keyword
;   - Purpose: Marks generic crew NPCs without flavor dialogue.
Keyword Property Crew_CrewTypeGeneric_NoflavorDialogue Auto

;----------------------------
; EVENT HANDLER
;----------------------------
Event OnInit()
    ; Wait until the player is fully loaded in 3D.
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile

    ; Populate the FormList dynamically.
    PopulateCrewList()

    Debug.Notification("DAC: Initialized. Checking collision state.")
    CheckAndToggleCollision()
EndEvent

;----------------------------
; 1) DYNAMIC FORM LIST POPULATION
;----------------------------
Function PopulateCrewList()
    ; Clear any existing entries.
    While FindNPCs.GetSize() > 0
        FindNPCs.RemoveAddedForm(FindNPCs.GetAt(0))
    EndWhile

    ; Get all currently loaded references using the Papyrus Extender.
    ObjectReference[] loadedRefs = CassiopeiaPapyrusExtender.GetLoadedReferences()
    If loadedRefs
        Int total = loadedRefs.Length
        Int i = 0
        While i < total
            Actor candidate = loadedRefs[i] as Actor

            ; Skip null or disabled actors.
            If candidate && !candidate.IsDisabled()
                ; Check if candidate is the player or Crew_Elite_Vasco.
                Bool isSpecialActor = (candidate == Game.GetPlayer()) || (candidate.GetBaseObject() == Crew_Elite_Vasco)
                ; Check if candidate has any of the relevant keywords.
                Bool hasCrewKeyword = candidate.HasKeyword(Crew_CrewTypeCompanion) || candidate.HasKeyword(Crew_CrewTypeElite) || candidate.HasKeyword(Crew_CrewTypeGeneric) || candidate.HasKeyword(Crew_CrewTypeGeneric_NoflavorDialogue)
                ; If any condition matches, add to the FormList.
                If isSpecialActor || hasCrewKeyword
                    FindNPCs.AddForm(candidate.GetBaseObject())
                EndIf
            EndIf
            i += 1
        EndWhile
    EndIf

    Debug.Notification("DAC: FormList populated with current Ship Crew NPCs.")
EndFunction

;----------------------------
; 2) COLLISION FUNCTIONS
;----------------------------
Function CheckAndToggleCollision()
    ; Check if the player is on the home spaceship.
    Bool isOnShip = CassiopeiaPapyrusExtender.IsOnPlayerHomeSpaceship(Game.GetPlayer())
    If isOnShip
        Debug.Notification("DAC: Player is on the home spaceship.")
    Else
        Debug.Notification("DAC: Player is off the home spaceship.")
    EndIf

    ; Call the appropriate collision function.
    If isOnShip
        DisableCollisionForShipNPCs()
    Else
        EnableCollisionForAllNPCs()
    EndIf
EndFunction

Function DisableCollisionForShipNPCs()
    ; Verify the FormList exists.
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Return
    EndIf

    ; Get the number of NPCs in the FormList.
    Int foundCount = FindNPCs.GetSize()
    Debug.Notification("DAC: Disabling collision for " + foundCount + " NPCs inside the ship.")

    ; Iterate over each NPC and disable collision.
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            ; If collision is already disabled, skip this actor.
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Notification("DAC: Skipping " + targetActor + " as it already has no collision.")
            Else
                CassiopeiaPapyrusExtender.DisableCollision(targetActor, True)
                Debug.Notification("DAC: Collision disabled for " + targetActor)
                CassiopeiaPapyrusExtender.InitHavok(targetActor)
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction

Function EnableCollisionForAllNPCs()
    ; Verify the FormList exists.
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Return
    EndIf

    ; Get the number of NPCs in the FormList.
    Int foundCount = FindNPCs.GetSize()
    Debug.Notification("DAC: Enabling collision for " + foundCount + " NPCs outside the ship.")

    ; Iterate over each NPC and enable collision.
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
            Debug.Notification("DAC: Collision enabled for " + targetActor)

            ; Get the player's position.
            Float playerX = Game.GetPlayer().GetPositionX()
            Float playerY = Game.GetPlayer().GetPositionY()
            Float playerZ = Game.GetPlayer().GetPositionZ()

            ; Offset the target actor's position.
            Float newX = targetActor.GetPositionX() + 3.0
            Float newY = targetActor.GetPositionY() + 3.0
            Float newZ = playerZ

            Debug.Notification("DAC: Set new position for " + targetActor + " to (" + newX + ", " + newY + ", " + newZ + ")")
            targetActor.SetPosition(newX, newY, newZ)
            CassiopeiaPapyrusExtender.InitHavok(targetActor)

            ; Verify that collision is enabled; if not, retry the same actor.
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Notification("DAC: Collision not enabled for " + targetActor + ", retrying.")
                i -= 1
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction
