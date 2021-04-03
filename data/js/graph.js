drag = simulation => {
  
    function dragstarted(event, d) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      d.fx = d.x;
      d.fy = d.y;
    }
    
    function dragged(event,d) {
      d.fx = event.x;
      d.fy = event.y;
    }
    
    function dragended(event,d) {
      if (!event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    }
    
    return d3.drag()
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended);
  };

const scale = d3.scaleOrdinal(d3.schemeCategory10);
color = d => scale(d.group);

height = 1100;
width = 2000;

function chart(data) {

    const links = data.links.map(d => Object.create(d));
    const nodes = data.nodes.map(d => Object.create(d));

    const simulation = d3.forceSimulation(nodes)
        .force("link", d3.forceLink(links).distance(100).id(d => d.id))
        .force("charge", d3.forceManyBody().strength(-2000))
        .force("x", d3.forceX())
        .force("y", d3.forceY());

    const svg = d3.create("svg")
        .attr("viewBox", [-width / 2, -height / 2, width, height]);

    svg.append('defs').append('marker')
        .attrs({'id':'arrowhead',
            'viewBox':'-0 -5 10 10',
            'refX':20,
            'refY':0,
            'orient':'auto',
            'markerWidth':30,
            'markerHeight':30,
            'xoverflow':'visible'})
        .append('svg:path')
        .attr('d', 'M 0,-5 L 10 ,0 L 0,5')
        .attr('fill', '#999')
        .style('stroke','none');

    const gLinks = svg.append("g");
    const link = gLinks
        .attr("stroke", "#999")
        .attr("stroke-opacity", 0.6)
    .selectAll("line")
    .data(links)
    .join("line")
        .attr("stroke-width", d => Math.sqrt(d.value))
        .attr('marker-end','url(#arrowhead)');

    const g = svg.append("g");
    const node = g
    .selectAll(".node")
    .data(nodes)
    // .join("circle")
    .enter().append('g')
        .attr("class", "node")
    //     .attr("r", 60)
    //     .attr("fill", color)
        .call(drag(simulation));

    node.append('circle')
        .attr("stroke", "#666")
        .attr("stroke-width", 1.5)
        .attr("r", 40)
        .attr("fill", color);

    node.append("title")
        .text(d => d.id);

    node.append("text")
        .attr("dy", ".3em")
        .style("text-anchor", "middle")
        .text(function(d) {
            if (typeof d.value == 'undefined')
                return;
            if (typeof d.value == 'string')
                return d.value;
            if (typeof d.value == 'object')
                if (typeof d.value.name == 'string')
                    return d.value.name;
                if (typeof d.value.first == 'string')
                return d.value.first;
        });
    simulation.on("tick", () => {
        link
            .attr("x1", d => d.source.x)
            .attr("y1", d => d.source.y)
            .attr("x2", d => d.target.x)
            .attr("y2", d => d.target.y);

        node.attr("transform", function(d){return "translate("+d.x+","+d.y+")"});

    });

    var zoom = d3.zoom().on("zoom", e => {
        gLinks.attr("transform", e.transform);
        g.attr("transform", e.transform);
    });

    // invalidation.then(() => simulation.stop());

    return svg
        .call(zoom)
        .node();
}

