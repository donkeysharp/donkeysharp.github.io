MESSAGE?=

add-worktree:
	@echo "Adding worktree to master branch in 'public' directory"
	@git worktree add -B master public origin/master

serve:
	@echo "Starting deveopment server"
	@hugo server --watch -D

deploy:
	@echo "Deploying content"
	./deploy.sh "$(MESSAGE)"
