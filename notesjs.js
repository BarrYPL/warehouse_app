<script>
        function GFG_FUN() {
            var cols = [];
            for (var i = 0; i < obj.length; i++) {
                for (var k in obj[i]) {
                    if (cols.indexOf(k) === -1) {
                        cols.push(k);
                    }
                }
            }
            var table = document.createElement("table");
            var tr = table.insertRow(-1);
             
            for (var i = 0; i < cols.length; i++) {
                var theader = document.createElement("th");
                theader.innerHTML = cols[i];
                tr.appendChild(theader);
            }
            for (var i = 0; i < obj.length; i++) {
                trow = table.insertRow(-1);
                for (var j = 0; j < cols.length; j++) {
                    var cell = trow.insertCell(-1);
                    cell.innerHTML = obj[i][cols[j]];
                }
            }
            var el = document.getElementById("table");
            el.innerHTML = "";
            el.appendChild(table);
        }   
		
		
		obj.forEach(obj => {
          Object.entries(obj).forEach(([key, value]) => {
            div.append(`${key} = ${value}`);
          });
          div.append('-------------------');
        });
</script>

localid name value quantity location