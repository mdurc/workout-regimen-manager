# workout-regimen-manager

Default workouts are beginner/intermediate gym and calisthenics workouts.
Simple workout reminder, stopwatch, scheduling app, an exercise-list display. Multiple saved workouts, cardio tracking, journaling/consistency tracking.

Widgets:
Displays the workout day (Pull Day, Push Day, Leg Day, Rest Day), inline, on lockscreen, based on the day of the week. Supports inline lockscreen, small, medium, and large widgets. 

Inlcudes stopwatch. Any edits made to a workout will be saved for the next day (if you edit Pull Day on Monday, it will be saved on Thursday as well). Widgets are refreshed when the save button is pressed in settings, saving the new workout (Only really significant for large widget that displays the workout of the day).

Motivation button: Unsplash API is used for random image search. Default search query is "kittens". Click or tap on image to find new image, or toggle the motivation button off and back on.

Changes automatically based on workout that is set for the current day of the week.<br>
<pre>Default Values:<br>
        Monday & Thursday: Pull Day<br>
        Tuesday & Friday: Push Day<br>
        Wednesday & Saturday: Leg Day<br>
        Sunday: Rest Day
</pre>

Customizability option which allows user to reorder which weekday has which workout plan, or even create a new workout plan such as "Cardio Day". Data saves the workout based on the workout plan name. So if you add Cardio Day to Monday and edit the workout text, and then add Cardio Day to Tuesday, the text will already be updated as it was on Monday.

<img src="https://github.com/mdurc/text-widget/assets/121322100/5b9668b4-fbe8-4c25-806d-364700860812" alt="inlineLockscreenWidget" width="234" height="506">

<img src="https://github.com/mdurc/text-widget/assets/121322100/38d85b7e-3186-4a8b-8749-11375325f4f8" alt="smallWidgetAndApp" width="234" height="506">

<img src="https://github.com/mdurc/text-widget/assets/121322100/587d5fb8-96d2-4ec5-bbd1-6fa003c1ac44" alt="largeAndSmallWidget" width="234" height="506">



Older Version that shows first features:

https://github.com/mdurc/workout-regimen-manager/assets/121322100/b4f8c080-fa32-4c62-a999-8de767d08add

Updated Version with newer features:

![UpdatedWorkoutApp](https://github.com/mdurc/workout-regimen-manager/assets/121322100/dd7b6fa4-9176-452c-95eb-c6b95462782f)

