Add and commit files with a clear, concise commit message following conventional commit format:

1. **Add files to staging:**
   - `git add <file>` - Add specific file
   - `git add .` - Add all changed files
   - `git add -A` - Add all changes including deletions

2. **Generate commit message:**
   - Use appropriate commit type (feat, fix, docs, style, refactor, test, chore)
   - Provide a brief but descriptive summary
   - Include breaking changes if applicable
   - Follow the project's commit message conventions

3. **Commit the changes:**
   - `git commit -m "type: description"`