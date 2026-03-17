# Errors Log

> Captured errors, failures, and exceptions for debugging and prevention.

---

## Format

```markdown
## [ERR-YYYYMMDD-XXX] skill_or_command_name

**Logged**: ISO-8601 timestamp
**Priority**: high
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
Brief description of what failed

### Error
```
Actual error message or output
```

### Context
- Command/operation attempted
- Input or parameters used
- Environment details if relevant

### Suggested Fix
If identifiable, what might resolve this

### Metadata
- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20250110-001 (if recurring)

---
```

## [ERR-20260317-001] git_force_push_destroyed_history

**Logged**: 2026-03-17T08:15:00+08:00
**Priority**: critical
**Status**: resolved
**Area**: infra

### Summary
Used `git push --force` without checking remote history, causing loss of multiple commits and files in the MGMakerDaily repository.

### Error
```
To github.com:hardihuang/MGMakerDaily.git
 + e0f5b9b...e31e801 master -> master (forced update)
```

### Context
- Attempted to update article-china-starlink.html with new video BV号
- Local repository had diverged from remote
- Used `git push origin master --force` instead of pulling first
- Remote had 9 commits with multiple articles, all were overwritten
- Only 2 commits remained after force push

### Suggested Fix
1. Always pull before pushing when working with shared repositories
2. Use `git fetch origin` first to check remote state
3. Prefer `git pull --rebase` or `git merge` over force push
4. If force push is necessary, use `--force-with-lease` instead of `--force`
5. Check `git log origin/master --oneline` before pushing

### Resolution
- **Resolved**: 2026-03-17T08:18:00+08:00
- **Method**: Used GitHub Events API to find previous commit SHA (e0f5b9b), then `git reset --hard` to restore
- **Recovery**: Successfully restored all 9 commits and files

### Metadata
- Reproducible: no (prevented)
- Related Files: mg-maker-daily/article-china-starlink.html
- Tags: git, force-push, data-loss, recovery
- Pattern-Key: harden.git_push_safety

---

*Add new errors below*
