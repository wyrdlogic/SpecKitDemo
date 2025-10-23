# Tasks: Tower Defense Resource Game

**Input**: Design documents from `/specs/001-tower-defense-game/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are MANDATORY per constitution principle "Test-Driven Excellence". All tasks must include unit, integration, and end-to-end tests following TDD methodology.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter web project**: `lib/`, `test/`, `web/` at repository root
- Paths follow MVVM architecture with Flame game engine integration

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Flutter/Flame structure

- [x] T001 Create Flutter web project structure per implementation plan
- [x] T002 [P] Add Flame game engine dependency to pubspec.yaml
- [x] T003 [P] Configure web platform settings in web/index.html
- [x] T004 [P] Setup dependency injection container in lib/core/service_locator.dart
- [x] T005 [P] Create game constants configuration in lib/core/constants.dart
- [x] T006 [P] Setup Dart extension methods in lib/utils/extensions.dart
- [x] T007 [P] Configure linting and formatting tools (analysis_options.yaml)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core MVVM architecture and Flame integration that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T008 Create base model classes and enums in lib/models/
- [x] T009 [P] Setup service interfaces following SOLID principles in lib/services/interfaces/
- [x] T010 [P] Create base ViewModel class with ChangeNotifier in lib/viewmodels/
- [x] T011 [P] Setup Flame game component base classes in lib/views/components/
- [x] T012 [P] Create utility classes in lib/utils/ (math_utils.dart, animation_utils.dart)
- [x] T013 Configure main.dart with Flame game integration and MVVM setup
- [x] T014 Setup test infrastructure and mocking framework in test/

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Basic Resource Generation and Wall Defense (Priority: P1) 🎯 MVP

**Goal**: Player can tap resource buttons, generate blue resources, upgrade wall, and see visual feedback

**Independent Test**: Launch game, tap blue resource button multiple times, accumulate resources, tap wall upgrade button, observe wall level increase and color change

### Tests for User Story 1 (MANDATORY - Constitution Principle II) ✅

> **TDD REQUIREMENT: Write these tests FIRST, ensure they FAIL, then implement minimal code to pass**

- [X] T015 [P] [US1] Unit test for Wall model in test/unit/models/wall_test.dart
- [X] T016 [P] [US1] Unit test for Resource model in test/unit/models/resource_test.dart
- [X] T017 [P] [US1] Unit test for ResourceViewModel in test/unit/viewmodels/resource_viewmodel_test.dart
- [X] T018 [P] [US1] Unit test for WallViewModel in test/unit/viewmodels/wall_viewmodel_test.dart
- [ ] T019 [P] [US1] Widget test for resource buttons in test/widget/components/resource_hud_test.dart
- [ ] T020 [P] [US1] Widget test for wall component in test/widget/components/wall_component_test.dart
- [ ] T021 [US1] Integration test for resource generation and wall upgrade flow in test/integration/us1_resource_upgrade_test.dart

### Implementation for User Story 1

- [X] T022 [P] [US1] Create Wall model in lib/models/wall.dart
- [X] T023 [P] [US1] Create Resource model in lib/models/resource.dart
- [X] T024 [P] [US1] Create IResourceManager interface in lib/services/interfaces/i_resource_manager.dart
- [X] T025 [US1] Create ResourceManagerService implementation in lib/services/resource_manager_service.dart
- [X] T026 [US1] Create ResourceViewModel in lib/viewmodels/resource_viewmodel.dart
- [X] T027 [US1] Create WallViewModel in lib/viewmodels/wall_viewmodel.dart
- [X] T028 [US1] Create WallComponent using Flame in lib/views/components/wall_component.dart
- [X] T029 [US1] Create ResourceHUD widget in lib/views/components/resource_hud.dart
- [ ] T030 [US1] Create basic GameView screen with resource UI in lib/views/game_view.dart
- [ ] T031 [US1] Wire up dependency injection for US1 services and ViewModels
- [ ] T032 [US1] Add validation and error handling for resource operations

**Checkpoint**: At this point, User Story 1 should be fully functional - player can generate resources and upgrade wall independently
- [ ] T030 [US1] Create basic GameView screen with resource UI in lib/views/game_view.dart
- [ ] T031 [US1] Wire up dependency injection for US1 services and ViewModels
- [ ] T032 [US1] Add validation and error handling for resource operations

**Checkpoint**: At this point, User Story 1 should be fully functional - player can generate resources and upgrade wall independently

---

## Phase 4: User Story 2 - Enemy Combat and Wall Health Management (Priority: P2)

**Goal**: Enemies spawn, move toward wall, deal damage, player can heal wall with green resources

**Independent Test**: Start wave, watch enemies spawn and move toward wall, let wall take damage, accumulate green resources, heal wall back to full health

### Tests for User Story 2 (MANDATORY - Constitution Principle II) ✅

- [X] T033 [P] [US2] Unit test for Enemy model in test/unit/models/enemy_test.dart
- [X] T034 [P] [US2] Unit test for EnemyViewModel in test/unit/viewmodels/enemy_viewmodel_test.dart
- [X] T035 [P] [US2] Unit test for EnemySpawnerService in test/unit/services/enemy_spawner_service_test.dart
- [ ] T036 [P] [US2] Widget test for enemy component in test/widget/components/enemy_component_test.dart
- [ ] T037 [US2] Integration test for enemy spawning, movement, and combat in test/integration/us2_enemy_combat_test.dart

### Implementation for User Story 2

- [X] T038 [P] [US2] Create Enemy model in lib/models/enemy.dart
- [X] T039 [P] [US2] Create IEnemySpawner interface in lib/services/interfaces/i_enemy_spawner.dart
- [X] T040 [US2] Create EnemySpawnerService implementation in lib/services/enemy_spawner_service.dart
- [X] T041 [US2] Create EnemyViewModel in lib/viewmodels/enemy_viewmodel.dart
- [X] T042 [US2] Create EnemyComponent using Flame in lib/views/components/enemy_component.dart
- [X] T043 [US2] Extend WallComponent to handle damage visualization and HP display
- [X] T044 [US2] Add healing functionality to ResourceHUD and WallViewModel
- [X] T045 [US2] Integrate enemy spawning and movement into GameView
- [X] T046 [US2] Add collision detection between enemies and wall
- [X] T047 [US2] Add game over condition when wall HP reaches zero
- [X] T048 [US2] Wire up dependency injection for US2 services and ViewModels

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - complete combat system functional

---

## Phase 5: User Story 3 - Complete Wave Survival and Level Progression (Priority: P3)

**Goal**: 60-second waves with timer, automatic progression, level-based difficulty scaling

**Independent Test**: Play complete 60-second wave, survive with wall HP remaining, advance to level 2, observe increased enemy difficulty

### Tests for User Story 3 (MANDATORY - Constitution Principle II) ✅

- [ ] T049 [P] [US3] Unit test for Wave model in test/unit/models/wave_test.dart
- [ ] T050 [P] [US3] Unit test for WaveViewModel in test/unit/viewmodels/wave_viewmodel_test.dart
- [ ] T051 [P] [US3] Unit test for DifficultyScalerService in test/unit/services/difficulty_scaler_service_test.dart
- [ ] T052 [US3] Integration test for complete wave cycle and progression in test/integration/us3_wave_progression_test.dart

### Implementation for User Story 3

- [ ] T053 [P] [US3] Create Wave model in lib/models/wave.dart
- [ ] T054 [P] [US3] Create GameState model in lib/models/game_state.dart
- [ ] T055 [P] [US3] Create IDifficultyScaler interface in lib/services/interfaces/i_difficulty_scaler.dart
- [ ] T056 [P] [US3] Create IGameEngine interface in lib/services/interfaces/i_game_engine.dart
- [ ] T057 [US3] Create DifficultyScalerService implementation in lib/services/difficulty_scaler_service.dart
- [ ] T058 [US3] Create GameEngineService implementation in lib/services/game_engine_service.dart
- [ ] T059 [US3] Create WaveViewModel in lib/viewmodels/wave_viewmodel.dart
- [ ] T060 [US3] Create GameViewModel coordinating all other ViewModels in lib/viewmodels/game_viewmodel.dart
- [ ] T061 [US3] Create WaveTimer widget in lib/views/components/wave_timer.dart
- [ ] T062 [US3] Integrate 60-second timer and wave progression logic
- [ ] T063 [US3] Add level-based enemy attribute scaling
- [ ] T064 [US3] Add victory conditions and level advancement
- [ ] T065 [US3] Create GameOverScreen in lib/views/screens/game_over_screen.dart
- [ ] T066 [US3] Wire up dependency injection for US3 services and ViewModels

**Checkpoint**: Complete core game loop functional - timer, progression, scaling all working

---

## Phase 6: User Story 4 - Resource Efficiency Optimization (Priority: P4)

**Goal**: Yellow resource generation and efficiency upgrades for strategic optimization

**Independent Test**: Accumulate yellow resources, purchase blue resource generation upgrades, observe faster resource accumulation

### Tests for User Story 4 (MANDATORY - Constitution Principle II) ✅

- [ ] T067 [P] [US4] Unit test for yellow resource upgrade logic in test/unit/viewmodels/resource_viewmodel_test.dart
- [ ] T068 [P] [US4] Widget test for resource upgrade UI in test/widget/components/resource_hud_test.dart
- [ ] T069 [US4] Integration test for resource efficiency optimization in test/integration/us4_resource_optimization_test.dart

### Implementation for User Story 4

- [ ] T070 [P] [US4] Extend Resource model to support generation rate upgrades
- [ ] T071 [US4] Add yellow resource upgrade logic to ResourceManagerService
- [ ] T072 [US4] Extend ResourceViewModel with upgrade functionality
- [ ] T073 [US4] Add resource upgrade buttons to ResourceHUD
- [ ] T074 [US4] Create GameControls widget in lib/views/components/game_controls.dart
- [ ] T075 [US4] Add exponential cost scaling to DifficultyScalerService
- [ ] T076 [US4] Integrate resource optimization UI into GameView

**Checkpoint**: All core user stories completed - strategic depth layer functional

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final game polish

- [ ] T077 [P] Create MenuScreen in lib/views/screens/menu_screen.dart
- [ ] T078 [P] Add game pause/resume functionality
- [ ] T079 [P] Implement responsive design for different screen sizes
- [ ] T080 [P] Add visual polish and animations using Flame effects
- [ ] T081 [P] Performance optimization for 60 FPS requirement
- [ ] T082 [P] Add accessibility features and keyboard controls
- [ ] T083 [P] Cross-browser compatibility testing and fixes
- [ ] T084 [P] Documentation updates in README.md
- [ ] T085 Run complete end-to-end validation using quickstart.md scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3 → P4)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Extends US1 wall functionality but independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Coordinates US1/US2 but independently testable  
- **User Story 4 (P4)**: Can start after Foundational (Phase 2) - Extends US1 resource system but independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation (TDD requirement)
- Models before services
- Services before ViewModels
- ViewModels before Views/Components
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test for Wall model in test/unit/models/wall_test.dart"
Task: "Unit test for Resource model in test/unit/models/resource_test.dart" 
Task: "Unit test for ResourceViewModel in test/unit/viewmodels/resource_viewmodel_test.dart"
Task: "Unit test for WallViewModel in test/unit/viewmodels/wall_viewmodel_test.dart"
Task: "Widget test for resource buttons in test/widget/components/resource_hud_test.dart"
Task: "Widget test for wall component in test/widget/components/wall_component_test.dart"

# Launch all models for User Story 1 together:
Task: "Create Wall model in lib/models/wall.dart"
Task: "Create Resource model in lib/models/resource.dart"
Task: "Create IResourceManager interface in lib/services/interfaces/i_resource_manager.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Basic Resource Generation and Wall Defense)
4. **STOP and VALIDATE**: Test User Story 1 independently - player can generate resources and upgrade wall
5. Deploy/demo MVP if ready

### Incremental Delivery

1. Complete Setup + Foundational → MVVM architecture ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP - basic resource management!)
3. Add User Story 2 → Test independently → Deploy/Demo (adds combat challenge!)
4. Add User Story 3 → Test independently → Deploy/Demo (complete game loop!)
5. Add User Story 4 → Test independently → Deploy/Demo (strategic optimization!)
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Resource system)
   - Developer B: User Story 2 (Enemy combat)
   - Developer C: User Story 3 (Wave progression)
   - Developer D: User Story 4 (Resource optimization)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- TDD requirement: Verify tests fail before implementing
- MVVM architecture: Models → ViewModels → Views separation maintained
- Flame integration: Use Flame components for game rendering, Flutter widgets for UI
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Target: 60 FPS performance on web platform with responsive design