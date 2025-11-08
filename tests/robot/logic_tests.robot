*** Settings ***
Library    tests.robot.lib.godot_keywords.GodotKeywords

*** Test Cases ***
Godot Logic Suite
    ${result}=    Run Godot Logic Tests
    Should Be True    ${result['success']}
    Log    ${result['summary']}
