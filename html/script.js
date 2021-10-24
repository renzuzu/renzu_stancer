const stancer = document.getElementById('container')
function playsound(table) {
    var file = table['file']
    var volume = table['volume']
    var audioPlayer = null;
    if (audioPlayer != null) {
        audioPlayer.pause();
    }
    if (volume == undefined) {
        volume = 0.1
    }
    audioPlayer = new Audio("./audio/" + file + ".ogg");
    audioPlayer.volume = 0.3;
    audioPlayer.play();
}

window.addEventListener('message', function(event) {
    var data = event.data;
    if (event.data.type == 'update') {
        SetProgressCircle(event.data.val)
    }
    if (event.data.type == 'playsound') {
        playsound(event.data.content)
    }
    if (event.data.type == 'show') {
        if (event.data.content.bool) {
            setShowCarcontrol(event.data.content)
            stancer.style.display = 'block';
        } else {
            stancer.style.display = 'none';
        }
    }

});

function setShowCarcontrol(table) {
    if (table.bool) {
        const settings = {
        fill: '#1abc9c',
        background: '#d7dcdf' };
        const suspension = document.querySelectorAll('#heightd');
        Array.prototype.forEach.call(suspension, slider => {
            const val = table.height * 100
            slider.querySelector('div').innerHTML = val.toFixed(1)
            slider.querySelector('input').value = val.toFixed(1)
            slider.querySelector('input').addEventListener('input', event => {
                slider.querySelector('div').innerHTML = event.target.value
                post("setvehicleheight",{val:event.target.value * 0.01})
            });
        });
    
        const wheeloffsetfront = document.querySelectorAll('#wheelofdiv');
        Array.prototype.forEach.call(wheeloffsetfront, slider => {
            const val = table.offset[1] * 10
            slider.querySelector('input').value = val.toFixed(1)
            slider.querySelector('div').innerHTML = val.toFixed(1)
            slider.querySelector('input').addEventListener('input', event => {
                slider.querySelector('div').innerHTML = event.target.value
                post("setvehiclewheeloffsetfront",{val:event.target.value})
            });
        });
    
        const wheeloffsetrear = document.querySelectorAll('#wheelordiv');
        Array.prototype.forEach.call(wheeloffsetrear, slider => {
            const val = table.offset[1] * 10
            slider.querySelector('input').value = val.toFixed(1)
            slider.querySelector('div').innerHTML = val.toFixed(1)
            slider.querySelector('input').addEventListener('input', event => {
                slider.querySelector('div').innerHTML = event.target.value
                post("setvehiclewheeloffsetrear",{val:event.target.value})
            });
        });
    
        const wheelrotationfront = document.querySelectorAll('#wheelrfdiv');
        Array.prototype.forEach.call(wheelrotationfront, slider => {
            const val = table.rotation[1] * 10
            slider.querySelector('input').value = val.toFixed(1)
            slider.querySelector('div').innerHTML = val.toFixed(1)
            slider.querySelector('input').addEventListener('input', event => {
                slider.querySelector('div').innerHTML = event.target.value
                post("setvehiclewheelrotationfront",{val:event.target.value})
            });
        });
    
        const wheelrotationrear = document.querySelectorAll('#wheelrrdiv');
        Array.prototype.forEach.call(wheelrotationrear, slider => {
            const val = table.rotation[1] * 10
            slider.querySelector('input').value = val.toFixed(1)
            slider.querySelector('div').innerHTML = val.toFixed(1)
            slider.querySelector('input').addEventListener('input', event => {
                slider.querySelector('div').innerHTML = event.target.value
                post("setvehiclewheelrotationrear",{val:event.target.value})
            });
        });
    }
}

function post(name,data){
	var name = name;
	var data = data;
    var xhr = new XMLHttpRequest()
    xhr.open("POST", "https://renzu_stancer/"+name, true)
    xhr.setRequestHeader('Content-Type', 'application/json')
    xhr.send(JSON.stringify(data))
}

document.getElementById('close').addEventListener('click', function() {
        post("wheelsetting",{bool:true})
        post('closecarcontrol',{})
}, false)