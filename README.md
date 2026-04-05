# resrobot-cli

CLI and AI agent skill for querying Swedish public transport schedules
via the [ResRobot API](https://www.trafiklab.se/api/our-apis/resrobot-v21/).

## Quick start

```bash
# Install
cp src/resrobot ~/.local/bin/
export PATH="$HOME/.local/bin/:$PATH"

# Set your API key (get one for free at trafiklab.se)
export RESROBOT_KEY="your-key-here"

# Try it
resrobot search "Göteborg"
resrobot departures "Stockholm Centralstation"
resrobot nearby "Drottninggatan 5, Uppsala"
resrobot trip "Kungsgatan 12, Malmö" "Lund Centralstation"
```

## Agent skill

`SKILL.md` teaches AI coding agents when and how to use the CLI.
Works with Claude Code, Kiro, GitHub Copilot, and other agents
supporting the [Agent Skills](https://agentskills.io/) open standard.

### Claude Code plugin

```bash
/plugin marketplace add mhssler/resrobot-cli
/plugin install resrobot-cli@resrobot-cli
```

### Manual install

Copy `SKILL.md` to your agent's skills directory (e.g. `~/.claude/skills/resrobot-cli/`).

## Commands

| Command | Description |
|---------|-------------|
| `search <name>` | Find stops by name |
| `nearby <address \| lat lon>` | Find stops near an address or coordinates |
| `departures <stop>` | Departures from a stop |
| `arrivals <stop>` | Arrivals at a stop |
| `trip <origin> <dest>` | Plan a trip between stops or addresses |
| `help [command]` | Show usage |

All commands support `--json` for raw API output.

## Dependencies

- bash (4.0+), curl, jq
- [ResRobot API key](https://www.trafiklab.se/) (free tier: 45 calls/min, 30k/month)
- Address geocoding uses [OpenStreetMap Nominatim](https://nominatim.openstreetmap.org/) (no key needed)

## Tests

```bash
# Unit tests (no API key needed)
bats tests/unit/

# Full suite (requires RESROBOT_KEY)
bash tests/run_tests.sh
```

## License

MIT
