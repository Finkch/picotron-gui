# picotron-gui

A library to help create a gui in the Picotron fantasy workstation.  
Requires an external library called `lib` with `vec.lua` and `kbm.lua`. Both of these are available in the [necrodancer](https://github.com/Finkch/picotron-necrodancer) repository.


## gui.lua

`gui.lua` creates a window and will update all containers and brains it possesses, and it will draw all containers it possesses. To create a full gui, make a gui class instance and populate it with containers and brains.  
The gui has a `.data` parameter which is a table. If containers require global access to data, place it within the `.data` parameter; or, do some other another approach - you don't have to listen to me, I'm just some readme file.  
When the gui is updated (`gui:update()`), is will call each of its containers and brains' `:update()` methods. Similarly, when the gui is drawn (`gui:draw()`), it will call each of its containers' `:draw()`; brains are not drawn. If a container has `.contents` and that contents has an `:update()` or `:draw()`, they will be called at its respective time.  
Containers and brains are both attached via calling the gui's `:attach()` method.  


## container.lua

### container types

Container are elements in the gui. There are four different types of containers: basic containers, labels, buttons, and sliders. Each serves a unique role.  
All other containers are built atop the basic container. A basic container can be used to display visuals by giving it some contents. They should not be used for input.  
Labels are typically used to inform the user of basic data, like text or a number. They are automatically sized to wrap a sprite or text, however their size can be specified to override this behaviour.  
Buttons are used to perform simple actions. While behaviour can be bound to any container, buttons are the first of the items on this list that should be interactable. They extend labels so sprites or text can be used for the button image. Buttons have an up-state (default state) and a down-state (active state). Upon entering the down state, they will perform their bound action for once.  
Sliders have a minimum and a maximum value. Clicking the slider will adjust its value between its range. While internally the slider's value is stored as a float between [0, 1], using the slider's `:get()` and `:put()` values will map a value out of or into (respectively) the slider.  


### more on containers

In all update and draw calls, the gui is passed to the container. This allows the container to access the gui's `.data` parameter.  
All containers can be deactivated, turning off some update functions and altering their appearence. So give logic to when a container is active, override its `:update_active()` method.  
If the gui's `.data` attribute has a `.mode` and the container has been given a `.mode`, then the container will deactivate while `gui.data.mode` does not match its own `.mode`.  
All containers have several empty update functions, such as `:when_clicked`, `:when_not_clicked`, and more that can be overloaded/overridden for functionality.  
All containers have an `:update()` and a `:draw()` method that are called by the gui. These should not be altered on a container-by-container basis but instead should act as defaults. For individual, conditionless alteratioins, adjust the container's `:update_extra()` or `:draw_extra()` methods.  


## brain.lua

Brain objects are one way of giving functionality to containers. Brains can be initialised with some data for easy referencing, or can use the gui's `.data` parameter, which is passed during update calls.  
To give a brains functionality, individually override their `:update()` methods and attatch them to the gui. Alternatively, setting a container's `.contents` to be a brain allows the brain to access the container's data.  
LabelBrain objects are a special brain to easily allow Labels to give data readouts. By constructing a LabelBrain with a `target` label and a data `source`, the target label will display the data. The source is required to have a `:get()` method (such as a slider), or the LabelBrain's own `:get()` command must be overridden.  


### other ways of giving containers functionality

Brains allow easy functionality that is able to reference the data within a container. If container data is not needed, then containers have many abstract update methods that can be overridden. A few of these are listed in [more on container](#more-on-containers).  