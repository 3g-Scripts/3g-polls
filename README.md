
# 3g-Polls

Lightweight, secure, **zero-SQL** voting/poll system for FiveM.  
Single active poll at a time, fast side-widget UI, fully server-validated with `ox_lib` callbacks and rate-limits.  

- Support: https://discord.gg/rZkJxeehTt  
- Docs: https://eyalg-developments.gitbook.io/docs/  
- More scripts
3g-codes: [Tebex](https://3gdev.tebex.io/package/6863233) • Video: [Click Here](https://www.youtube.com/watch?v=mNzENYu5mRs)

---

## Features

- 🔒 Server-side validation for **every** action (create, submit, UI pushes)
- 🧠 Memory-only cache (no DB), per-player ballot via robust identifier
- 🗳️ One poll at a time (enforced server-side)
- 🪶 Ultra-low ms usage; idle NUI, efficient diff updates
- 🪟 Side widget shows the most urgent poll; **/vote** toggles click-through focus
- 🧰 Creator modal (admin only) or quick command parsing
- 📣 Auto announcement when a poll starts and when it ends (winner)
- ⚙️ Configurable durations, option caps, widget size, commands
- 🧰 ESX/QBCore admin detection + ACE

---

## Requirements

- **ox_lib** (load before this resource)
- Optional: **ESX** or **QBCore** (for admin permission detection), otherwise ACE is used

---

## Installation

1. Drop the folder **`3g-polls`** into your `resources` directory.
2. Ensure dependencies in `server.cfg`:
```

ensure ox_lib
ensure 3g-polls

````
3. UI is prebuilt in `web/build`.

---

## Configuration

`shared/config.lua`

```lua
Config = {}

Config.Commands = {
  Start  = 'startvote',   -- /startvote 300 Title | Opt A | Opt B | Opt C
  Open   = 'vote',        -- toggles widget click/focus
  Toggle = 'votetoggle'   -- show/hide widget (view-only)
}

Config.Durations = { Min = 30, Max = 3600, Default = 300 }

Config.MaxOptions = 10

Config.Widget = {
  MaxOptions = 5          -- max options visible in the widget
}

Config.Notify = { Position = 'top-right', Duration = 5000 }
```

---

## Usage

### Create a poll (Admin)

* **Command modal:** `/startvote` → opens the Create Poll modal
* **Quick command:**

  ```
  /startvote <duration> <title> | <opt1> | <opt2> [| opt3 | ...]
  ```

  Example:

  ```
  /startvote 300 What should we do next? | Heist | Race | Chill
  ```

> Only one poll can run at a time. The server enforces this.

### Vote

* The side-widget appears for everyone when a poll starts.
* Click an option directly in the widget (no focus needed) **only** when you toggle interaction:

  * `/vote` → toggles widget **interaction** (NUI focus on/off)
* Hide or show the widget without interaction:

  * `/votetoggle`

### End behavior

* On timeout, the poll ends automatically.
* Winner is announced in a toast.
* Focus is released and the widget hides.

---

## Security & Validation

* All client pushes (including “openCreate”, “state”, “ended”, “visibility”, “interact”, “toggle”) are **validated on the server** via `ox_lib` callbacks before UI updates.
* `VM` (server manager) enforces **single active poll** and duration clamps.
* **Rate limits** (server-side): create & submit.
* Ballots keyed by best identifier: `license:` → `discord:` → `steam:` → `fivem:` → `src:<id>`.
* No SQL; everything is in memory for speed and simplicity.

---

## Commands

* `/startvote` – Admin only. Opens creator if no args; or parses a single-line definition.
* `/vote` – Toggles widget interaction (focus on/off) if a poll is active.
* `/votetoggle` – Show/hide widget (view-only).

### Admin detection

* ESX group: `admin`/`superadmin`
* QBCore permission: `admin`/`god`
* ACE: `admin` or `command` allowed

---

## File Structure

```
3g-polls/
  fxmanifest.lua
  shared/
    config.lua
  client/
    client.lua            -- NUI <-> game bridge, focus & widget state
  server/
    server.lua            -- callbacks, commands, validation, glue
    classes/
      vote.lua            -- Vote class (cache + tally + toClient)
      manager.lua         -- VM (create/submit/list/enforce single poll)
  web/
    build/                -- prebuilt React/NUI (index.html, assets)
```

---

## NUI Actions (internal)

The NUI frame receives structured actions:

* `setWidget { on: boolean }`
* `syncVote { data: Vote }`
* `syncVotes { data: Vote[] }`
* `announce { text: string }`
* `openCreate`, `closeAll`
* `hideWidget`
* `setInteract { on: boolean }`

And emits:

* `submitVote { id, option }`
* `createVote { title, duration, options[] }`
* `hoverOn` / `hoverOff`

All are wrapped with `ox_lib` callbacks on the server.

---

## Performance

* Idle **\~0.00–0.01ms** on server and client.
* NUI runs only when visible; event diff renders; batched DOM updates; throttled timers.

---

## Troubleshooting

* **“bad cast GetResourceKvp…”**
  Ensure KVP reads happen inside a client thread and the value is treated as string/number appropriately (the resource already guards this).
* **No icons**
  The React build includes the icons used by the widget and modal. If you customize, keep the icon components or include your icon pack in `index.html`.
* **No active poll**
  `/vote` only toggles interaction when a poll is running by design.

---

## Links

* Support: [https://discord.gg/rZkJxeehTt](https://discord.gg/rZkJxeehTt)
* Docs: [https://eyalg-developments.gitbook.io/docs/](https://eyalg-developments.gitbook.io/docs/)
* 3g-codes: [https://3gdev.tebex.io/package/6863233](https://3gdev.tebex.io/package/6863233) • [https://www.youtube.com/watch?v=mNzENYu5mRs](https://www.youtube.com/watch?v=mNzENYu5mRs)

---

## License

All rights reserved © 3gdev.
