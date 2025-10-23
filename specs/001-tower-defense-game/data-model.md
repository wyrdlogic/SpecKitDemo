# Data Model: Tower Defense Resource Game

**Generated**: October 23, 2025  
**Feature**: Tower Defense Resource Game  
**Source**: Extracted from functional requirements in spec.md

## Core Entities

### Wall
Central defensive structure that players must protect.

**Fields**:
- `currentHP: int` - Current hit points (0 to maxHP)
- `maxHP: int` - Maximum hit points for current level  
- `level: int` - Wall upgrade level (starts at 1)
- `color: Color` - Visual appearance that changes with level
- `position: Offset` - Screen position for rendering

**Validation Rules**:
- currentHP ≥ 0 and currentHP ≤ maxHP
- maxHP > 0 and increases with level upgrades
- level ≥ 1
- position must be within screen bounds

**State Transitions**:
- Upgrade: level++, maxHP increases exponentially, color changes
- Damage: currentHP decreases by enemy damage amount
- Heal: currentHP increases up to maxHP limit
- Destroyed: currentHP = 0 triggers game over

### Enemy
Attacking units that move toward the wall and deal damage.

**Fields**:
- `hp: int` - Enemy hit points
- `damage: int` - Damage dealt per attack
- `speed: double` - Movement speed (pixels per frame)
- `position: Offset` - Current screen position
- `target: Offset` - Wall position (movement target)
- `isAlive: bool` - Active state flag
- `attackCooldown: int` - Frames between attacks

**Validation Rules**:
- hp > 0 when alive
- damage > 0
- speed > 0
- position within screen bounds during movement
- attackCooldown ≥ 0

**State Transitions**:
- Spawn: created with level-scaled attributes
- Move: position updates toward target each frame
- Attack: deals damage when reaching wall, cooldown resets
- Despawn: removed when wall is destroyed or wave ends

### Resource
Game currency system with three types for different upgrades.

**Fields**:
- `type: ResourceType` - Blue, Green, or Yellow
- `amount: int` - Current quantity owned
- `generationRate: double` - Resources per second
- `isGenerating: bool` - Active generation state
- `lastGenerationTime: DateTime` - For calculation timing

**Validation Rules**:
- amount ≥ 0
- generationRate ≥ 0
- type must be valid ResourceType enum value

**State Transitions**:
- Generate: amount increases by rate over time when isGenerating = true
- Spend: amount decreases by upgrade costs (with validation)
- UpgradeRate: generationRate increases via yellow resource investment

### Wave
Timed game session that controls enemy spawning and level progression.

**Fields**:
- `duration: int` - Wave length in seconds (60)
- `remainingTime: int` - Countdown timer
- `level: int` - Current difficulty level  
- `isActive: bool` - Wave running state
- `enemySpawnRate: double` - Enemies per second
- `enemiesSpawned: int` - Count for current wave

**Validation Rules**:
- duration > 0
- remainingTime ≥ 0 and ≤ duration
- level ≥ 1
- enemySpawnRate > 0
- enemiesSpawned ≥ 0

**State Transitions**:
- Start: isActive = true, timer begins countdown
- Tick: remainingTime decreases, enemies spawn based on rate
- Complete: remainingTime = 0, level++, prepare next wave
- Fail: triggered when wall HP = 0

### GameState
Root state container that coordinates all game entities.

**Fields**:
- `wall: Wall` - Player's defensive structure
- `enemies: List<Enemy>` - Active enemy instances
- `resources: Map<ResourceType, Resource>` - All resource types
- `currentWave: Wave` - Active wave information
- `gameStatus: GameStatus` - Playing, Paused, GameOver, Victory
- `gameStartTime: DateTime` - For session tracking

**Validation Rules**:
- wall cannot be null
- enemies list can be empty but not null
- resources map must contain all ResourceType values
- currentWave cannot be null when gameStatus = Playing

**State Transitions**:
- Initialize: Set up starting values for new game
- Update: Process frame-by-frame game logic updates
- Pause: Suspend timers and enemy movement
- Resume: Restore active game state
- End: Set GameOver status, preserve final state

## Entity Relationships

```
GameState (1:1) Wall
GameState (1:many) Enemy  
GameState (1:3) Resource [Blue, Green, Yellow]
GameState (1:1) Wave

Wave (spawns) Enemy
Enemy (attacks) Wall
Resource (upgrades) Wall
Resource (heals) Wall  
Resource (improves) Resource [yellow upgrades generation rates]
```

## Data Flow Patterns

**Resource Generation**: Timer → Resource.amount++ → UI Update
**Wall Upgrade**: Resource.spend() → Wall.upgrade() → Visual Change
**Enemy Attack**: Enemy.reachWall() → Wall.takeDamage() → HP Update → Game Over Check
**Wave Progression**: Timer.complete() → Wave.next() → Enemy.scaleAttributes() → New Wave Start

## Validation Constraints

**Cross-Entity Rules**:
- Wall upgrades require sufficient blue resources
- Healing cannot exceed wall's current maxHP
- Resource spending must validate available amounts
- Enemy spawning rate scales with wave level
- Game over triggers when wall.currentHP = 0

**Performance Constraints**:
- Enemy list size limited to maintain 60 FPS (estimated max 20 concurrent)
- Resource calculations must complete within single frame
- State updates must be atomic to prevent inconsistent game state