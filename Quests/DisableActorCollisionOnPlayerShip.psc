ScriptName DAC:Quests:DisableActorCollisionOnPlayerShip Extends Quest

RefCollectionAlias Property FindNPCs Auto ; Uses the alias already set in CK

Event OnInit()
    While !Game.GetPlayer().Is3DLoaded()
        Utility.Wait(1.0)
    EndWhile
    Debug.Notification("DAC: Initialized. Checking collision state.")
    CheckAndToggleCollision()
EndEvent

Function CheckAndToggleCollision()
    Bool isOnShip = CassiopeiaPapyrusExtender.IsOnPlayerHomeSpaceship(Game.GetPlayer())
    If isOnShip
        Debug.Notification("DAC: Player is on the home spaceship.")
    Else
        Debug.Notification("DAC: Player is off the home spaceship.")
    EndIf
    
    If isOnShip
        DisableCollisionForShipNPCs()
    Else
        EnableCollisionForAllNPCs()
    EndIf
EndFunction

Function DisableCollisionForShipNPCs()
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs alias is None!")
        Return
    EndIf
    Int foundCount = FindNPCs.GetCount()
    Debug.Notification("DAC: Disabling collision for " + foundCount + " NPCs inside the ship.")
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            ; Check if the actor has no collision
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
    If FindNPCs == None
        Debug.Notification("DAC: ERROR - FindNPCs alias is None!")
        Return
    EndIf
    Int foundCount = FindNPCs.GetCount()
    Debug.Notification("DAC: Enabling collision for " + foundCount + " NPCs outside the ship.")
    Int i = 0
    While i < foundCount
        Actor targetActor = FindNPCs.GetAt(i) as Actor
        If targetActor && targetActor != Game.GetPlayer() && targetActor.Is3DLoaded()
            CassiopeiaPapyrusExtender.DisableCollision(targetActor, False)
            Debug.Notification("DAC: Collision enabled for " + targetActor)
            
            ; Get the player's position
            Float playerX = Game.GetPlayer().GetPositionX()
            Float playerY = Game.GetPlayer().GetPositionY()
            Float playerZ = Game.GetPlayer().GetPositionZ()
            
            ; Offset the target actor's position
            Float newX = targetActor.GetPositionX() + 3.0
            Float newY = targetActor.GetPositionY() + 3.0
            Float newZ = playerZ
            
            ; Set the new position for the target actor
            Debug.Notification("DAC: Set new position for " + targetActor + " to (" + newX + ", " + newY + ", " + newZ + ")")
            targetActor.SetPosition(newX, newY, newZ)
            CassiopeiaPapyrusExtender.InitHavok(targetActor)
            
            ; Verify collision is enabled
            If CassiopeiaPapyrusExtender.HasNoCollision(targetActor)
                Debug.Notification("DAC: Collision not enabled for " + targetActor + ", retrying.")
                i -= 1 ; Retry the same actor
            EndIf
        EndIf
        i += 1
    EndWhile
EndFunction
