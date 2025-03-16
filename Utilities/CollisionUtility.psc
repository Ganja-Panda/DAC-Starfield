;======================================================================
; Script: DAC:Utilities:CollisionUtility_SingleFunction
; Description: This global utility script performs the following tasks
;              all within a single function:
;              1) Initializes its required objects via GetFormFromFile.
;              2) Waits until the player is fully loaded.
;              3) Clears and dynamically populates a FormList with NPCs
;                 that match specific criteria.
;              4) Iterates over the FormList to enable collision on the NPCs.
;======================================================================

ScriptName DAC:Utilities:CollisionUtility Extends ScriptObject

Function RunCollisionUtility() Global
    ;---------------------------------------------------
    ; 1) Initialize Local Variables via GetFormFromFile
    ;---------------------------------------------------
    ; Replace "Starfield.esm" with your actual plugin name.
    FormList localFindNPCs = Game.GetFormFromFile(0x00000808, "Starfield.esm") as FormList
    ActorBase localCrewEliteVasco = Game.GetFormFromFile(0x000157BB, "Starfield.esm") as ActorBase
    Keyword localCrewTypeCompanion = Game.GetFormFromFile(0x002705E4, "Starfield.esm") as Keyword
    Keyword localCrewTypeElite = Game.GetFormFromFile(0x00270729, "Starfield.esm") as Keyword
    Keyword localCrewTypeGeneric = Game.GetFormFromFile(0x00270728, "Starfield.esm") as Keyword
    Keyword localCrewTypeGeneric_NoFlavor = Game.GetFormFromFile(0x00E54321, "Starfield.esm") as Keyword

    ;---------------------------------------------------
    ; 2) Wait for the Player to be Fully Loaded (3D)
    ;---------------------------------------------------
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile

    ;---------------------------------------------------
    ; 3) Clear Existing Entries in the FormList
    ;---------------------------------------------------
    While localFindNPCs.GetSize() > 0
        localFindNPCs.RemoveAddedForm(localFindNPCs.GetAt(0))
    EndWhile

    ;---------------------------------------------------
    ; 4) Populate the FormList with Matching NPCs
    ;---------------------------------------------------
    ObjectReference[] loadedRefs = CassiopeiaPapyrusExtender.GetLoadedReferences()
    If loadedRefs
        Int total = loadedRefs.Length
        Int i = 0
        While i < total
            Actor candidate = loadedRefs[i] as Actor
            If candidate && !candidate.IsDisabled()
                ; Determine if the candidate is the player or the special actor.
                Bool isSpecialActor = (candidate == Game.GetPlayer()) || (candidate.GetBaseObject() == localCrewEliteVasco)
                ; Check if the candidate has any of the crew keywords.
                Bool hasCrewKeyword = candidate.HasKeyword(localCrewTypeCompanion) || candidate.HasKeyword(localCrewTypeElite) || candidate.HasKeyword(localCrewTypeGeneric) || candidate.HasKeyword(localCrewTypeGeneric_NoFlavor)
                ; If either condition is met, add the candidate's base form.
                If isSpecialActor || hasCrewKeyword
                    localFindNPCs.AddForm(candidate.GetBaseObject())
                EndIf
            EndIf
            i += 1
        EndWhile
    EndIf

    Debug.Notification("DAC: FormList populated with current Ship Crew NPCs.")

    ;---------------------------------------------------
    ; 5) Enable Collision for All NPCs in the FormList
    ;---------------------------------------------------
    If localFindNPCs == None
        Debug.Notification("DAC: ERROR - localFindNPCs FormList is None!")
        Return
    EndIf

    Int foundCount = localFindNPCs.GetSize()
    Debug.Notification("DAC: Enabling collision for " + foundCount + " NPCs now.")

    Int j = 0
    While j < foundCount
        Actor targetActor = localFindNPCs.GetAt(j) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
            Debug.Notification("DAC: Collision enabled for " + targetActor)
            CassiopeiaPapyrusExtender.InitHavok(targetActor)
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Notification("DAC: Collision not enabled for " + targetActor + ", retrying.")
                j -= 1
            EndIf
        EndIf
        j += 1
    EndWhile

    Debug.Notification("DAC: CollisionUtility run complete.")
EndFunction
