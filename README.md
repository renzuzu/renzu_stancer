# renzu_stancer
- Fivem Stancer - Vehicle Adjustable Wheel Offsets, Rotatin and Suspension Height

# Feats
- Item Supported (Install Stancer Kit)
- Multiple Framework (QBCORE, ESX, Standalone)
- Adjustable Wheel Offsets and Rotation ( Stancer )
- Adjustable Vehicle Suspension Height
- Fully Server Sync (One Sync and Infinity only)
- Optimized System (Nearby Vehicles are only looped in client)
- Data is Saved to Database (Attached to Plate)
- One Sync State Bag system to avoid callbacks and triggerevents for data sharing from client to server.
- NUI Based and User Friendly Interface.

# Image
![image](https://user-images.githubusercontent.com/82306584/138594316-54f0b7ee-a20c-4d6e-9186-983409461ebb.png)
![image](https://user-images.githubusercontent.com/82306584/138594321-f4467b1f-19fd-4ce3-99a7-dc99243f7f3b.png)


# Install
- Installation:
- Drag renzu_stancer to your resource folder and start at server.cfg
- Import stancer.sql
- ensure renzu_stancer


# Framework Usage: 
- use item inside vehicle
- /giveitem 1 stancerkit 1
- /stancer or F5 (keybind Default)

# Standalone Usage
- Press F5


# ITEMS
- stancerkit

# dependency 
- ESX,QBCORE

# Exports for advanced usage

- Server Exports

- Add Stancer Kit to Current Vehicle
```
	exports.renzu_stancer:AddStancerKit()
```

- Client Exports 
(to use this, AddStancerKit() exports must be used first 
or the vehicle must have a installed stancer kit)

- Set Wheel Offset Front
```
	exports.renzu_stancer:SetWheelOffsetFront(vehicle,value)
```
- Set Wheel Offset Rear
```
	exports.renzu_stancer:SetWheelOffsetRear(vehicle,value)
```
- Set Wheel Rotation Front
```
	exports.renzu_stancer:SetWheelRotationFront(vehicle,value)
```
- Set Wheel Rotation Rear
```
	exports.renzu_stancer:SetWheelRotationRear(vehicle,value)
```
- Open Stancer Menu
```
	exports.renzu_stancer:OpenStancer()
```
# FAQ
- is the stance or wheel setting is saved even if i restart the server?
```
	yes data is save to database and attached to vehicle plate as a unique identifier
```

- when the data is being saved to Database?
```
When you delete the vehicle or store in garage
```
