~/go/bin/hugo
cd public
git init 
git add .
git commit -m "Rebuilding site"
git remote add origin git@github.com:cronokirby/cronokirby.github.io
git push --force origin master
cd ..
