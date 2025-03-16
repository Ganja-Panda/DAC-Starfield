;======================================================================
; Script: DAC:Utilities:CollisionUtility
; Description: This global utility script dynamically populates a FormList
;              with NPCs matching certain conditions and enables collision
;              on them. The properties are assigned at runtime via GetFormFromFile,
;              since we cannot set these manually in CK.
;======================================================================

ScriptName DAC:Utilities:CollisionUtility Extends ScriptObject

;----------------------------
; Property Definitions
;----------------------------

; FindNPCs:
;   - Type: FormList
;   - Purpose: Holds NPC base forms for collision handling.
;   - Example FormID: 0x00000808
FormList FindNPCs

; Crew_Elite_Vasco:
;   - Type: ActorBase
;   - Purpose: Special NPC always included in checks.
;   - Example FormID: 0x000157BB
ActorBase Crew_Elite_Vasco

; Crew_CrewTypeCompanion:
;   - Type: Keyword
;   - Purpose: Marks companion-type crew NPCs.
;   - Example FormID: 0x002705E4
Keyword Crew_CrewTypeCompanion

; Crew_CrewTypeElite
;   - Type: Keyword
;   - Purpose: Marks elite crew NPCs.
;   - Example FormID: 0x00270729
Keyword Crew_CrewTypeElite

; Crew_CrewTypeGeneric:
;   - Type: Keyword
;   - Purpose: Marks generic crew NPCs.
;   - Example FormID: 0x00270728
Keyword Crew_CrewTypeGeneric

; Crew_CrewTypeGeneric_NoflavorDialogue:
;   - Type: Keyword
;   - Purpose: Marks generic crew NPCs that should not have flavor dialogue.
;   - Example FormID: 0x00009C0B
Keyword Crew_CrewTypeGeneric_NoflavorDialogue

;----------------------------
; INITIALIZATION FUNCTION
;----------------------------

Function InitProperties()
    ; Replace "Starfield.esm" with the actual name of your mod plugin.
    FindNPCs = Game.GetFormFromFile(0x00000808, "Starfield.esm") as FormList
    Crew_Elite_Vasco = Game.GetFormFromFile(0x000157BB, "Starfield.esm") as ActorBase
    Crew_CrewTypeCompanion = Game.GetFormFromFile(0x002705E4, "Starfield.esm") as Keyword
    Crew_CrewTypeElite = Game.GetFormFromFile(0x00D45678, "Starfield.esm") as Keyword
    Crew_CrewTypeGeneric = Game.GetFormFromFile(0x00E12345, "Starfield.esm") as Keyword
    Crew_CrewTypeGeneric_NoflavorDialogue = Game.GetFormFromFile(0x00E54321, "Starfield.esm") as Keyword
EndFunction

;----------------------------
; GLOBAL FUNCTIONS
;----------------------------

; PopulateCrewList:
; Clears FindNPCs and repopulates it by scanning loaded references for actors
; that are the player, match Crew_Elite_Vasco, or have any of the crew keywords.
Function PopulateCrewList() Global
    ; Clear existing entries using RemoveAddedForm().
    While FindNPCs.GetSize() > 0
        FindNPCs.RemoveAddedForm(FindNPCs.GetAt(0))
    EndWhile

    ; Get all currently loaded references via the Papyrus Extender.
    ObjectReference[] loadedRefs = CassiopeiaPapyrusExtender.GetLoadedReferences()
    If loadedRefs
        Int total = loadedRefs.Length
        Int i = 0
        While i < total
            Actor candidate = loadedRefs[i] as Actor
            If candidate && !candidate.IsDisabled()
                ; Check if candidate is the player or the special actor.
                Bool isSpecialActor = (candidate == Game.GetPlayer()) || (candidate.GetBaseObject() == Crew_Elite_Vasco)
                ; Check if candidate has any of the crew keywords.
                Bool hasCrewKeyword = candidate.HasKeyword(Crew_CrewTypeCompanion) || candidate.HasKeyword(Crew_CrewTypeElite) || candidate.HasKeyword(Crew_CrewTypeGeneric) || candidate.HasKeyword(Crew_CrewTypeGeneric_NoflavorDialogue)
                If isSpecialActor || hasCrewKeyword
                    FindNPCs.AddForm(candidate.GetBaseObject())
                EndIf
            EndIf
            i += 1
        EndWhile
    EndIf

    Debug.Notification("DAC: FormList populated with current Ship Crew NPCs.")
EndFunction

; EnableCollisionForAllNPCsNow:
; Iterates over FindNPCs and enables collision for each NPC that is 3D loaded
; (excluding the player). If collision isn’t enabled, it retries the same NPC.
Function EnableCollisionForAllNPCsNow() Global
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs FormList is None!")
        Return
    EndIf

    Int foundCount = FindNPCs.GetSize()
    Debug.Notification("DAC: Enabling collision for " + foundCount + " NPCs now.")

    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
            Debug.Notification("DAC: Collision enabled for " + targetActor)
            CassiopeiaPapyrusExtender.InitHavok(targetActor)
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Notification("DAC: Collision not enabled for " + targetActor + ", retrying.")
                i -= 1
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction

;----------------------------
; EVENT HANDLER
;----------------------------

Event OnInit()
    ; Initialize property values using GetFormFromFile.
    InitProperties()

    ; Optionally, delay until the player is fully loaded.
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile

    ; Populate the crew list dynamically.
    PopulateCrewList()

    Debug.Notification("DAC: CollisionUtility initialized.")
EndEvent
