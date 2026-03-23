# Potato Planner

A cozy iOS productivity app that combines a time-based daily planner with a <i>Stephania erecta</i> plant (aka potato plant) progression system.
<p float="left">
  <img width="250" src="https://github.com/user-attachments/assets/184c3752-6b42-4ae8-8407-ed1b2329bc53" />
  <img width="250" src="https://github.com/user-attachments/assets/52933b45-40ce-4a17-a271-a10df1c45f21" />
  <img width="250" src="https://github.com/user-attachments/assets/56f2fca7-db82-465d-af1c-6db5b2f686bd" />
</p>

## Features
- **Daily tasks**: add tasks with a title, description, and time estimate
- **Focus sessions**: start a focus timer tied to a task
- **Potato progression**: earn fertilizer and spuds from focused time to grow potatoes and buy new ones
- **Calendar view**: look at tasks by date and plan ahead

## Implementation
- **Swift + SwiftUI**
- **SwiftData**
- **MVVM architecture**

## Project Structure
```text
 PotatoPlanner/
  ├── App/                    # App entry point
  ├── ViewModels/             # PotatoPlannerStore: business logic and SwiftData access
  ├── Models/                 # SwiftData models, PotatoCatalog, SessionResult, Configs
  ├── Views/
  │   ├── Tasks/              # Daily view, individual tasks, add/edit, focus timer
  │   ├── Potatoes/           # Potato collection, potato detail, purchase/equip potatoes
  │   ├── Calendar/           # Monthly calendar view
  │   └── Overlays/           # Reward, level-up, purchase, and confetti popups
  ├── Design/                 # UI components: video background, theme modifiers
  └── Utilities/              # Date and Int extensions
```
