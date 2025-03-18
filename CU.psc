;======================================================================
; Script: DAC:Utilities:CU (Enhanced Debugging)
; Description: This utility script retrieves alias collection dynamically
;              and enables collision on NPCs, with additional debug logs.
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

    RefCollectionAlias FindNPCs = myQuest.GetAlias(3) as RefCollectionAlias
    If FindNPCs == None
        Debug.Notification("DAC: Alias not found in quest.")
        Return
    EndIf
    Debug.Notification("DAC: Alias found.")

    ;---------------------------------------------------
    ; Wait for the Player to be Fully Loaded (3D)
    ;---------------------------------------------------
    While !Game.GetPlayer().Is3DLoaded()
        Debug.Notification("DAC: Waiting for player 3D load.")
        Utility.Wait(1.0)
    EndWhile
    Debug.Notification("DAC: Player 3D loaded.")

    ;---------------------------------------------------
    ; Ensure Alias Collection Has NPCs
    ;---------------------------------------------------
    Debug.Notification("DAC: Checking alias collection count.")
    Int aliasCount = FindNPCs.GetCount()
    Debug.Notification("DAC: Alias count is " + aliasCount)
    If aliasCount == 0
        Debug.Notification("DAC: No NPCs found in alias collection.")
        Return
    EndIf
    Debug.Notification("DAC: Found " + aliasCount + " NPCs in alias collection.")

    ;---------------------------------------------------
    ; Enable Collision for All NPCs in Alias Collection
    ;---------------------------------------------------
    Int j = 0
    While j < aliasCount
        Debug.Notification("DAC: Attempting to retrieve actor at index " + j)
        Actor targetActor = FindNPCs.GetAt(j) as Actor
        If targetActor
            Debug.Notification("DAC: Retrieved actor: " + targetActor)

            ; Ensure actor is loaded before processing
            While !targetActor.Is3DLoaded()
                Debug.Notification("DAC: Waiting for " + targetActor + " to load.")
                Utility.Wait(1.0)
            EndWhile
            Debug.Notification("DAC: " + targetActor + " is now 3D loaded.")

            ; Skip player
            If targetActor != Game.GetPlayer()
                Debug.Notification("DAC: Attempting to disable collision for " + targetActor)
                Bool success = CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
                If success
                    Debug.Notification("DAC: DisableCollision succeeded for " + targetActor)
                Else
                    Debug.Notification("DAC: DisableCollision failed for " + targetActor)
                EndIf
                CassiopeiaPapyrusExtender.UpdateReference3D(targetActor)
            Else
                Debug.Notification("DAC: Skipping player actor.")
            EndIf
        Else
            Debug.Notification("DAC: Actor at index " + j + " is None. Possible issue with alias filling.")
        EndIf
        j += 1
    EndWhile

    Debug.Notification("DAC: CollisionUtility run complete.")
EndFunction
