run-robot-tests:
	# ========== Starting Robot Tests =============================================
	robot --exclude Blocked -L DEBUG -d ./robot_test_results/ ./robot_test_cases/
	# ========== Finished Running Robot Tests ======================================
run-tagged-tests:
	# ========== Starting Robot Tests =============================================
	robot -i '${tag}' --exclude Blocked -L DEBUG -d ./robot_test_results/ ./robot_test_cases/
	# ========== Finished Running Robot Tests ======================================