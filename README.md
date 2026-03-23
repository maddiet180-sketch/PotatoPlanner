# Potato Planner

A cozy iOS productivity app that combines a time-based daily planner with a <i>Stephania erecta</i> plant (aka potato plant) progression system.
<p float="left">
  <img src="https://github.com/user-attachments/assets/2659ff46-3bbe-4aee-8aa4-1e25572ca81b" width="250" />
  <img src="https://github.com/user-attachments/assets/eea3cab7-7928-4c28-abcf-fe31dbf7b7d9" width="250" />
  <img src="https://github.com/user-attachments/assets/ca1e7f93-16c9-49c6-a97b-2ca00c457656" width="250" />
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
  ├── App/                    # Entry point, owns ModelContainer and Store
  ├── ViewModels/             # PotatoPlannerStore — all business logic and SwiftData access
  ├── Models/                 # SwiftData models, PotatoCatalog, SessionResult, Configs
  ├── Views/
  │   ├── Tasks/              # Daily view, individual tasks, add/edit, focus timer
  │   ├── Potatos/            # Potato collection, detail, purchase, equip
  │   ├── Calendar/           # Monthly calendar view
  │   └── Overlays/           # Reward, level-up, purchase, confetti popups
  ├── Design/                 # Custom UI components, video background, theme modifiers
  └── Utilities/              # Date and Int extensions
'''
