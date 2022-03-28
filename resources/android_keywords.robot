*** Settings ***
Documentation   Variables and keywords for Virta interveiw cases
Library         AppiumLibrary   10
Library         String

*** Variables ***
${REMOTE_URL}                   http://127.0.0.1:4723/wd/hub  
${ANDROID_AUTOMATION_NAME}      UIAutomator2
${ANDROID_PLATFORM_NAME}        Android
${ANDROID_PLATFORM_VERSION}     %{ANDROID_PLATFORM_VERSION=12}
${WINDOW_ANIMATIONS}            true

*** Keywords ***
Open wallpaper and style settings
    Open Application    ${REMOTE_URL}    automationName=${ANDROID_AUTOMATION_NAME}  
    ...  platformName=${ANDROID_PLATFORM_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}  
    ...  appPackage=com.google.android.apps.wallpaper  appActivity=com.android.customization.picker.CustomizationPickerActivity
    ...  noReset=true   disableWindowAnimation=${WINDOW_ANIMATIONS}
    
Open clock application
    Open Application  http://127.0.0.1:4723/wd/hub  automationName=${ANDROID_AUTOMATION_NAME}
    ...  platformName=${ANDROID_PLATFORM_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}  
    ...  appPackage=com.google.android.deskclock  appActivity=com.android.deskclock.DeskClock
    ...  noReset=true   disableWindowAnimation=${WINDOW_ANIMATIONS}

Open phone application
    Open Application  http://127.0.0.1:4723/wd/hub  automationName=${ANDROID_AUTOMATION_NAME}
    ...  platformName=${ANDROID_PLATFORM_NAME}  platformVersion=${ANDROID_PLATFORM_VERSION}  
    ...  appPackage=com.android.dialer  appActivity=.main.impl.MainActivity
    ...  noReset=true   disableWindowAnimation=${WINDOW_ANIMATIONS}

Set wallpaper
    Select random wallpaper category
    Select random wallpaper and save

Select random wallpaper category

    Swipe                                   540     1800       540      300                                             # Swipe to get all categorie visible
    ${wallpaper_categories}                 Get Webelements         com.google.android.apps.wallpaper:id/tile
    ${category_count}                       Get Length              ${wallpaper_categories}
    ${selected_category}                    Evaluate                random.randint(1, ${category_count})      random    # Select random category, starting from 1 to make sure that my photos are not selected 
    Click Element                           ${wallpaper_categories}[${selected_category}]

Select random wallpaper and save
    Swipe                                   540     1800       540      300
    ${wallpapers}                           Get Webelements         com.google.android.apps.wallpaper:id/thumbnail
    ${wallpaper_count}                      Get Length              ${wallpapers}
    ${selected_wallpaper}                   Evaluate                random.randint(0, ${wallpaper_count})      random   #Starting randomisin from 2 to leave my photos out
    Click Element                           ${wallpapers}[${selected_wallpaper}]
    Wait Until Element Is Visible           com.google.android.apps.wallpaper:id/action_apply
    Click Element                           com.google.android.apps.wallpaper:id/action_apply
    ${set_wallpaper}                        Run Keyword And Return Status       Wait Until Element Is Visible           com.google.android.apps.wallpaper:id/set_home_wallpaper_button
    Run Keyword If                          ${set_wallpaper}==${True}           Click Element                           com.google.android.apps.wallpaper:id/set_home_wallpaper_button

Add new contact with random name and number
    Click Element                           com.android.dialer:id/contacts_tab
    ${empty_list}                           Run Keyword And Return Status       Get Webelement          com.android.dialer:id/empty_list_view_action
    Run Keyword If                          ${empty_list}==${True}              Click Element           com.android.dialer:id/empty_list_view_action
    Run Keyword If                          ${empty_list}==${False}             Click Text              Create new contact
    Wait Until Element Is Visible           class=android.widget.EditText
    Enter contact data

Enter contact data
    Wait Until Element Is Visible           class=android.widget.EditText
    ${elements}                             Get Webelements         class=android.widget.EditText
    ${first_name}                           Generate Random String      8       [LOWER]
    ${last_name}                            Generate Random String      10      [LOWER]
    ${number}                               Generate Random String      10      [NUMBERS]
    Input Text                              ${elements}[0]        ${first_name}
    Input Text                              ${elements}[1]        ${last_name}
    Input Text                              ${elements}[2]        ${number}
    Click Element                           com.android.contacts:id/editor_menu_save_button
    Set test variable                       ${first_name}
    Set test variable                       ${last_name}
    Set test variable                       ${number}
    
Verify added contact	
    Wait Until Element Is Visible           com.android.contacts:id/title_gradient
    Page Should Contain Text                ${first_name} ${last_name}

Remove existing alarms
    ${return_value}                         Run Keyword And Return Status    Get Webelements     com.google.android.deskclock:id/arrow
    @{existing_alarms}                      Run Keyword If    ${return_value}==${True}    Get Webelements     com.google.android.deskclock:id/arrow     # Get existing alarms 
    FOR    ${alarm}         IN              @{existing_alarms}
        Wait Until Element Is Visible       ${alarm}
        Click Element                       ${alarm}
        Wait Until Element Is Visible       com.google.android.deskclock:id/delete  
        Click Element                       com.google.android.deskclock:id/delete      # Delete alarm
    END

Select alarm view
    Click Text      Alarm

Add alarm
    [Arguments]     ${alarm_hour}           ${alarm_min}    ${am_pm}       ${alarm_label}      ${vibrating}
    Wait Until Element Is Visible           com.google.android.deskclock:id/fab
    Click Element                           com.google.android.deskclock:id/fab
    Wait Until Element Is Visible           android:id/ampm_layout
    Run Keyword If                          '${am_pm}'=='AM'        Click Element       android:id/am_label
    Run Keyword If                          '${am_pm}'=='PM'        Click Element       android:id/pm_label
    Click Element                           android:id/toggle_mode
    Input Text                              android:id/input_hour       ${alarm_hour}
    Input Text                              android:id/input_minute     ${alarm_min}
    Click Element                           android:id/button1
    Set vibrating on off                    ${vibrating}
    Set alarm label                         ${alarm_label}

Set vibrating on off
    [Arguments]     ${vibrating}
    Wait Until Element Is Visible           com.google.android.deskclock:id/vibrate_onoff
    ${checked}                              Get Element Attribute           com.google.android.deskclock:id/vibrate_onoff       checked
    Run Keyword If                          '${vibrating}'!='${checked}'    Click Element       com.google.android.deskclock:id/vibrate_onoff

Set alarm label
    [Arguments]     ${label}
    Click Element                           com.google.android.deskclock:id/edit_label
    Wait Until Element Is Visible           com.google.android.deskclock:id/label_input_field
    Input Text                              com.google.android.deskclock:id/label_input_field       ${label}
    Click Element                           android:id/button1

Write alarm count to log
    ${existing_alarms}                      Get Webelements     com.google.android.deskclock:id/arrow
    ${alarms}                               Get Length              ${existing_alarms}
    log     ****** amount of alarms ${alarms} ******

Return to home screen
    Press Keycode       3
    Wait Until Element Is Visible           com.google.android.apps.nexuslauncher:id/g_icon
    
Capture screenshot
    [Arguments]     ${ss_name}
    Capture Page Screenshot                 ${ss_name}


