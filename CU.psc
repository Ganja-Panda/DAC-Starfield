;======================================================================
; Script: DAC:Utilities:CU
; Description: This global utility script performs the following tasks
;              all within a single function:
;              1) Retrieves alias collection dynamically from QST_DAC_DisableCollision.
;              2) Waits until the player is fully loaded.
;              3) Uses a RefCollectionAlias to find NPCs.
;              4) Iterates over the Alias Collection to enable collision on the NPCs.
;======================================================================

ScriptName DAC:CU extends ScriptObject

Function RunCU() Global
    Debug.Notification("DAC: RunCU function called.")
    
    Quest myQuest = Game.GetFormFromFile(0x0000080D, "DAC.esm") as Quest  ; Retrieve the quest
    If myQuest == None
        Debug.Notification("DAC: Quest not found.")
        Return
    EndIf
    Debug.Notification("DAC: Quest found.")

    ; Use the actual index of the alias in your quest
    RefCollectionAlias FindNPCs = myQuest.GetAlias(3) as RefCollectionAlias
    If FindNPCs == None
        Debug.Notification("DAC: Alias not found in quest.")
        Return
    EndIf
    Debug.Notification("DAC: Alias found.")

    ;---------------------------------------------------
    ; 1) Wait for the Player to be Fully Loaded (3D)
    ;---------------------------------------------------
    While !Game.GetPlayer().Is3DLoaded()
        Debug.Notification("DAC: Waiting for player 3D load.")
        Utility.Wait(1.0)
    EndWhile
    Debug.Notification("DAC: Player 3D loaded.")

    ;---------------------------------------------------
    ; 2) Ensure Alias Collection Has NPCs
    ;---------------------------------------------------
    If FindNPCs.GetCount() == 0
        Debug.Notification("DAC: No NPCs found in alias collection.")
        Return
    EndIf
    Debug.Notification("DAC: Enabling collision for " + FindNPCs.GetCount() + " NPCs now.")

    ;---------------------------------------------------
    ; 3) Enable Collision for All NPCs in Alias Collection
    ;---------------------------------------------------
    Int foundCount = FindNPCs.GetCount()
    Int j = 0
    While j < foundCount
        Actor targetActor = FindNPCs.GetAt(j) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
            Debug.Notification("DAC: Collision enabled for " + targetActor)
            CassiopeiaPapyrusExtender.UpdateReference3D(targetActor)
            ;CassiopeiaPapyrusExtender.InitHavok(targetActor)
            ;If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
            ;    Debug.Notification("DAC: Collision not enabled for " + targetActor + ", retrying.")
            ;    j -= 1
            ;EndIf
        EndIf
        j += 1
    EndWhile

    Debug.Notification("DAC: CollisionUtility run complete.")
EndFunction
