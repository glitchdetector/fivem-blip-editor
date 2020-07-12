let selSprd = null;
let selCold = null;

let sendData = (field, value) => {
    console.log({field: field, value: value});
    $.post('http://blip-editor/return', JSON.stringify({type: field, data: value}));
}

let receiveData = (field, value) => {
    switch (field) {
        case 'sprite':
            $("#blip_" + value).click();
            break;
        case 'color':
            $("#col_" + value).click();
            break;
        case 'scale':
            scalerange.value = value;
            scalerange.onchange();
            break;
        case 'alpha':
            alpharange.value = value;
            alpharange.onchange();
            break;
        // case 'rotation':
        //     rotationrange.value = value;
        //     rotationrange.onchange();
        //     break;
        case 'name':
            inp_name.value = value;
            inp_name.onchange();
            break;
        case 'bHideLegend':
            bHideLegend.checked = value;
            break;
        case 'bAlwaysVisible':
            bAlwaysVisible.checked = value;
            break;
        case 'bCheckmark':
            bCheckmark.checked = value;
            break;
        case 'bHeightIndicator':
            bHeightIndicator.checked = value;
            break;
        case 'bHeadingIndicator':
            bHeadingIndicator.checked = value;
            break;
        case 'bShrink':
            bShrink.checked = value;
            break;
        case 'bOutline':
            bOutline.checked = value;
            break;
        default:
            $("#" + field).value = value;
            break;
    }
}

window.addEventListener('message', (ev) => {
    let method = ev.data.method;
    let data = ev.data.data;

    switch (method) {
        case 'open':
            main.style['display'] = 'block';
            break;
        case 'close':
            main.style['display'] = 'none';
            break;
        default:
            receiveData(method, data);
            break;
    }
})

beDisp = () => {main.style['display'] = 'block'};
beHide = () => {main.style['display'] = 'none'};

window.onload = () => {
    let sprd = document.getElementById('sprites');
    let cold = document.getElementById('colors');
    let sprp = document.getElementById('spritepreview');
    let colp = document.getElementById('colorpreview');
    let sprites = spriteList();
    let colors = colorList();
    for (let sprite of sprites) {
        let elem = document.createElement('img');
        elem.src = sprite[1];
        elem.setAttribute('class', 'sprite');
        elem.setAttribute('id', 'blip_' + sprite[0]);
        elem.onclick = () => {
            sprp.innerHTML = "";
            if (selSprd != null) {
                selSprd.setAttribute('class', 'sprite');
            }
            elem.setAttribute('class', 'sprite sprite-selected');
            selSprd = elem;
            sendData("sprite", sprite[0]);
            let clone = selSprd.cloneNode(true);
            clone.style['vertical-align'] = 'text-bottom';
            sprp.appendChild(clone);
        }
        sprd.appendChild(elem);
    }
    for (let color of colors) {
        let elem = document.createElement('div');
        elem.style['background-color'] = '#' + color[2];
        elem.setAttribute('class', 'color');
        elem.setAttribute('id', 'col_' + color[0]);
        elem.onclick = () => {
            colp.innerHTML = "";
            if (selCold != null) {
                selCold.setAttribute('class', 'color');
            }
            elem.setAttribute('class', 'color color-selected');
            selCold = elem;
            sendData("color", color[0]);
            let preview = document.createElement('span');
            preview.setAttribute('class', 'badge');
            preview.appendChild(document.createTextNode(color[1]));
            preview.style['padding'] = '2px';
            preview.style['border-radius'] = '6px';
            preview.style['border'] = '4px solid #' + color[2];
            colp.appendChild(preview);
        }
        cold.appendChild(elem);
    }

    scalerange.oninput = () => {
        let val = (scalerange.value / 10).toFixed(2);
        scalerangepreview.innerHTML = val;
        sendData("scale", scalerange.value);
    }
    scalerange.onchange = scalerange.oninput;

    alpharange.oninput = () => {
        let val = alpharange.value;
        let percent = Math.round((val / 255) * 100);
        alpharangepreview.innerHTML = percent;
        sendData("alpha", val);
    }
    alpharange.onchange = alpharange.oninput;

    // rotationrange.oninput = () => {
    //     let val = rotationrange.value;
    //     rotationrangepreview.innerHTML = val;
    //     sendData("rotation", val);
    // }
    // rotationrange.onchange = rotationrange.oninput;

    bHideLegend.onchange = () => {
        sendData("bHideLegend", bHideLegend.checked);
    }
    bAlwaysVisible.onchange = () => {
        sendData("bAlwaysVisible", bAlwaysVisible.checked);
    }
    bCheckmark.onchange = () => {
        sendData("bCheckmark", bCheckmark.checked);
    }
    bHeightIndicator.onchange = () => {
        sendData("bHeightIndicator", bHeightIndicator.checked);
    }
    bHeadingIndicator.onchange = () => {
        sendData("bHeadingIndicator", bHeadingIndicator.checked);
    }
    bShrink.onchange = () => {
        sendData("bShrink", bShrink.checked);
    }
    bOutline.onchange = () => {
        sendData("bOutline", bOutline.checked);
    }

    inp_name.oninput = () => {
        sendData("name", inp_name.value);
    }
    inp_name.onchange = inp_name.oninput;

    btn_discard.onclick = () => {
        sendData("finish", "discard");
    }
    btn_save.onclick = () => {
        sendData("finish", "save");
    }
    btn_delete.onclick = () => {
        sendData("finish", "delete");
    }
}
