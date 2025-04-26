# 🎬 Strapi CMS – Film & Review Collection Setup

This project demonstrates a local Strapi setup for creating and managing custom content types: **Film** and **Review**, with a one-to-many relationship. Built using the official `create-strapi-app` tool.

---

## 🚀 Setup Overview

### ✅ Project Created With:
```bash
yarn create strapi-app my-strapi-project --quickstart

## This sets up Strapi with SQLite and launches it automatically at:

http://localhost:1337/admin

-----------------------------------------------------------------

🏗️ Collection Types Created
🎞️ Film

    Field	                     Type
    title	                     Text
    director	                 Text
    released_date	             Date
    plot	                     Rich Text

-------------------------------------------------------------

📝 Review

    Field	                     Type
    rating	                     Number
    review_text	                 Rich Text
    film	                     Relation (Many-to-One → Film)

# A Film can have many Reviews, and each Review belongs to one Film.

-----------------------------------------------------------------------------------------

🧪 Sample Entries
    &&  Added and published sample Film entries (e.g., Inception, Interstellar)

    &&  Added multiple Review entries linked to those films

    &&  Verified content in the admin panel


--------------------------------------------------------------------------------

🌐 Local Development:
        
        yarn develop

Admin panel: http://localhost:1337/admin

--------------------------------------------------------------------------------

🔀 Git & GitHub
    Branch Created:
   
     git checkout -b "branch_name"

Changes Pushed:
   
    git add .
    git commit -m "Commit message"
    git push origin "barnch_name"

---------------------------------------------------------------

✅ Outcome
    🎉 Successfully deployed Strapi locally

    🧱 Created content types: Film and Review

    🔗 Linked them via one-to-many relationship

    📝 Populated and published sample content

    📤 Committed code and raised a Pull Request

-----------------------------------------------------------------------
