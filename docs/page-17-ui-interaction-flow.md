# User Screen Interaction Diagram

This diagram shows the User interacting with the screens from the outside, with all screens grouped inside a single container representing the **LeafCloud Mobile App**.

![LeafCloud UI Interaction Flow](/Users/fil/.gemini/antigravity-cli/brain/8cf038e5-14a1-41d5-9859-d98fc173a56d/ui_interaction_flow.png)

---

### Mermaid Source Code

If you need to edit or recompile the diagram, here is the original Mermaid source:

```mermaid
flowchart LR
    %% Define Styles
    classDef userNode fill:#E1F5FE,stroke:#0288D1,stroke-width:3px,color:#01579B;
    classDef screenNode fill:#E8F5E9,stroke:#4E7A43,stroke-width:2px,color:#2E4F28;
    classDef adminScreenNode fill:#FFF3E0,stroke:#F57C00,stroke-width:2px,color:#E65100;
    
    %% User outside the app
    User((User / Operator))
    
    %% App Container (Square/Rectangle boundary)
    subgraph App ["LeafCloud Mobile App"]
        %% Screens
        Login(["LoginPage"])
        Home(["HomePage & Dashboard"])
        Alerts(["AlertsScreen"])
        History(["HistoryScreen"])
        Configs(["ConfigListPage"])
        ConfigEdit(["ConfigPage"])
        Profile(["ProfilePage"])
        
        %% Admin Screens
        Calibration(["CalibrationScreen"])
        Register(["RegisterPage"])
    end
    
    %% Interactions
    User -->|Logs in & connects| Login
    User -->|Monitors system health| Home
    User -->|Reads nutrient notifications| Alerts
    User -->|Views historical graphs| History
    User -->|Views configs list| Configs
    User -->|Creates or edits config| ConfigEdit
    User -->|Manages credentials| Profile
    
    User -->|Calibrates pH/EC sensors| Calibration
    User -->|Registers new accounts| Register

    %% Class assignments
    class User userNode;
    class Login,Home,Alerts,History,Configs,ConfigEdit,Profile screenNode;
    class Calibration,Register adminScreenNode;
    
    %% Style Subgraph container
    style App fill:#FAFAFA,stroke:#B0BEC5,stroke-width:2px,stroke-dasharray: 5 5;
```
