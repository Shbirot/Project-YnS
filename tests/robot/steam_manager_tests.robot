*** Settings ***
Library    tests.robot.lib.godot_keywords.GodotKeywords

*** Variables ***
${CASE_DIR}    res://tests/robot/cases

*** Test Cases ***
Steam Manager Spec
    Run Single Case    ${CASE_DIR}/steam_manager_test.gd

*** Keywords ***
Run Single Case
    [Arguments]    ${case_path}
    Run Godot Logic Case    ${case_path}
