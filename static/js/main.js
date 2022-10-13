function write_data(){
    let content = document.getElementById('content');
    for(var i=0;i<data.length;i++){
        content.innerHTML = content.innerHTML + data[i].title + "<br/>";
    }
}

write_data();