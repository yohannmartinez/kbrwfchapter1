require('!!file-loader?name=[name].[ext]!../index.html')
require('!!file-loader?name=[name].[ext]!../tuto.webflow/orders.html')
require('!!file-loader?name=[name].[ext]!../tuto.webflow/order_details.html')

/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var Qs = require('qs')
var Cookie = require('cookie')
var When = require('when')
var XMLHttpRequest = require("xhr2")
var createReactClass = require('create-react-class')

var orders = [
  { remoteid: "000000189", custom: { customer: { full_name: "TOTO & CIE" }, billing_address: "Some where in the world" }, items: 2 },
  { remoteid: "000000190", custom: { customer: { full_name: "Looney Toons" }, billing_address: "The Warner Bros Company" }, items: 3 },
  { remoteid: "000000191", custom: { customer: { full_name: "Asterix & Obelix" }, billing_address: "Armorique" }, items: 29 },
  { remoteid: "000000192", custom: { customer: { full_name: "Lucky Luke" }, billing_address: "A Cowboy doesn't have an address. Sorry" }, items: 0 },
]





var Layout = createReactClass({
  getInitialState: function () {
    return { modal: this.props.modal };
  },

  modal(modal_data) {
    this.setState({
      modal: {
        ...modal_data, callback: (res) => {
          this.setState({ modal: null }, () => {
            if (modal_data.callback) modal_data.callback(res)
          })
        }
      }
    })
  },

  render() {
    var modal_component = {
      'delete': (props) => <DeleteModal {...props} />
    }[this.state.modal && this.state.modal.type];
    modal_component = modal_component && modal_component(this.state.modal)

    var props = {
      ...this.props, modal: this.modal
    }

    return <JSXZ in="orders" sel=".layout" onClick={() => { console.log(modal_component) }}>
      <Z sel=".layout-container">

        <Search {...this.props} />
        <Header {...props} />
        <Bottom {...this.props} />
      </Z>
      <Z sel=".modal-wrapper" className={cn(classNameZ, { 'hidden': !modal_component })}>
        {modal_component}
      </Z>
    </JSXZ>
  }
})

var cn = function () {
  var args = arguments, classes = {}
  for (var i in args) {
    var arg = args[i]
    if (!arg) continue
    if ('string' === typeof arg || 'number' === typeof arg) {
      arg.split(" ").filter((c) => c != "").map((c) => {
        classes[c] = true
      })
    } else if ('object' === typeof arg) {
      for (var key in arg) classes[key] = arg[key]
    }
  }
  return Object.keys(classes).map((k) => classes[k] && k || '').join(' ')
}

var DeleteModal = createReactClass({
  render() {
    console.log("i am the delete modal and my props are", this.props)
    return <JSXZ in="orders" sel=".modal-wrapper">
      <Z sel=".modal-text">
        {this.props.message}
      </Z>
      <Z sel=".modal-confirm-button" onClick={() => { this.props.callback(true) }}>
        yes delete it !
      </Z>
      <Z sel=".modal-cancel-button" onClick={() => { this.props.callback(false) }}>
        no, go back
      </Z>
    </JSXZ>
  }
})



var Search = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".div-global-search">
      <Z sel=".div-search" onSubmit={(e) => { e.preventDefault(); window.location.href = `/?page=0&rows=30&sort=creation_date_int&${document.getElementById("Search").value}` }}>
        <ChildrenZ />
      </Z>
    </JSXZ>
  }
})

var Header = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".header">
      <Z sel=".header-container">
        <ChildrenZ />
      </Z>
      <Z sel=".orders">
        <Orders {...this.props} />
      </Z>
    </JSXZ>
  }
})

var Bottom = createReactClass({
  range(array, showedNumber) {
    const range = [];

    for(let i = 0; i < Math.ceil(array / showedNumber); i++){
      range.push(i + 1);
    }

    return range
  },
  render() {
    let range = this.range(this.props.orders.value.response.numFound, Number(this.props.qs.rows))
    return <JSXZ in="orders" sel=".div-global-button">
      <Z sel=".pages-container">
        {range.map((page,index)=>(
          <div className="page-number" style={{color : Number(this.props.qs.page) === index ? "red" : "black"}} onClick={()=>{GoTo("orders","", {page : String(index), rows : this.props.qs.rows, sort : this.props.qs.sort})}}>{page}</div>
        ))}
      </Z>
    </JSXZ>
  }
})

var LayoutOrder = createReactClass({
  render() {
    return <JSXZ in="order_details" sel=".layout">
      <Z sel=".layout-container">
        <Order {...this.props} />
      </Z>
    </JSXZ>
  }
})

var Child = createReactClass({
  render() {
    var [ChildHandler, ...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      console.log("route is orders")
      return (path == "/") && { handlerPath: [Layout, Header, Orders] }
    }
  },
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path)
      console.log("path of order is", r)
      return r && { handlerPath: [LayoutOrder, Order], order_id: r[1] }
    }
  }
}

var remoteProps = {
  // user: (props)=>{
  //   return {
  //     url: "/api/me",
  //     prop: "user"
  //   }
  // },
  orders: (props) => {
    // if (!props.user)
    //   return
    // var qs = { ...props.qs, user_id: props.user.value.id }
    var qs = { ...props.qs }
    var query = Qs.stringify(qs)
    console.log("query are", query)
    return {
      url: "/api/orders" + (query == '' ? '' : '?' + query),
      prop: "orders"
    }
  },
  order: (props) => {
    return {
      url: "/api/order/" + props.order_id,
      prop: "order"
    }
  }
}

function addRemoteProps(props) {
  console.log("addRemoteProps", props)
  return new Promise((resolve, reject) => {
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c) => c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
        .filter((p) => p) // -> [[remoteProps.user], [remoteProps.orders]]
    )

    var remoteProps = remoteProps
      .map((spec_fun) => spec_fun(props)) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
      // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
      .filter((specs) => specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs) => !props[specs.prop] || props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if (remoteProps.length == 0) { return resolve(props) }

    var promise = When.map( // Returns a Promise that either on a list of resolved remoteProps, or on the rejected value by the first fetch who failed 
      remoteProps.map((spec) => { // Returns a list of Promises that resolve on list of resolved remoteProps ([{url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}])
        return HTTP.get(spec.url)
          .then((result) => { spec.value = result; return spec }) // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'} 
      })
    )

    When.reduce(promise, (acc, spec) => { // {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
      acc[spec.prop] = { url: spec.url, value: spec.value }
      return acc
    }, props).then((newProps) => {
      addRemoteProps(newProps).then(resolve, reject)
    }, reject)
  })
}

var HTTP = new (function () {
  this.get = (url) => this.req('GET', url)
  this.delete = (url) => this.req('DELETE', url)
  this.post = (url, data) => this.req('POST', url, data)
  this.put = (url, data) => this.req('PUT', url, data)

  this.req = (method, url, data) => new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept", "application/json,*/*;0.8")
    req.setRequestHeader("content-type", "application/json")
    req.onload = () => {
      if (req.status >= 200 && req.status < 300) {
        resolve(req.responseText && JSON.parse(req.responseText))
      } else {
        reject({ http_code: req.status })
      }
    }
    req.onerror = (err) => {
      reject({ http_code: req.status })
    }
    req.send(data && JSON.stringify(data))
  })
})()

var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders]
  },
  render() {
    console.log("link is http://localhost:4001/?page=0&rows=30&sort=creation_date_index")
    return (
      <JSXZ in="orders" sel=".orders">
        <Z sel=".table-body">
          {this.props.orders.value.response.docs.map(order => (<JSXZ in="orders" sel=".table-line" >
            <Z sel=".table-col1">{order._yz_rk}</Z>
            <Z sel=".table-col2">{order["custom.customer.full_name"]}</Z>
            <Z sel=".table-col3">{order["custom.customer.last_name"]}</Z>
            <Z sel=".table-col4">{order.creation_date_int}</Z>
            <Z sel=".table-col5" onClick={() => { GoTo("order", order.remoteid) }}>{"->"}</Z>
            <Z sel=".table-col6" onClick={() => {
              this.props.modal({
                type: 'delete',
                title: 'Order deletion',
                message: `Are you sure you want to delete this ?`,
                callback: (reload) => {
                  console.log("callback", reload)
                  //Do something with the return value
                  if (reload) {
                    HTTP.delete("/api/order/delete/" + order.remoteid).then((result) => {
                      GoTo("/")
                    })
                  }
                }
              })
            }}>delete</Z>
          </JSXZ>))}
        </Z>
      </JSXZ>
    )
  }
})

var Order = createReactClass({
  statics: {
    remoteProps: [remoteProps.order]
  },
  render() {
    return <JSXZ in="order_details" sel=".header">
      <Z sel=".order">
        <JSXZ in="order_details" sel=".principal-order-info">
          <Z sel=".client">name: {this.props.order.value.custom.customer.full_name}</Z>
          <Z sel=".address">address: {this.props.order.value.custom.billing_address}</Z>
          <Z sel=".command-number">command number: {this.props.order.value.remoteid}</Z>
        </JSXZ>

      </Z>
    </JSXZ>
  }
})



var browserState = { Child: Child }

var GoTo = (route, params, query) => {
  console.log("GO TO CALLED !!!", "route is", route, "params are", params, "query is", Qs.stringify(query))
  var qs = Qs.stringify(query)
  console.log("query of goto is", qs)
  var url = routes[route].path(params) + ((qs == '') ? '' : ('?' + qs))
  console.log(url)
  history.pushState({}, "", url)
  onPathChange()
}

function onPathChange() {
  console.log("onPathChange !!!!")
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)
  console.log(path, qs, cookies)

  browserState = {
    ...browserState,
    path: path,
    qs: qs,
    cookie: cookies
  }

  var route, routeProps
  //We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs)
    if (routeProps) {
      route = key
      break;
    }
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }

  addRemoteProps(browserState).then(
    (props) => {
      console.log("adding remote props")
      browserState = props
      //Log our new browserState
      //Render our components using our remote data
      ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code} />, document.getElementById('root'))
    })

  //If we don't have a match, we render an Error component
  if (!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404} />, document.getElementById('root'))
  ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
}

window.addEventListener("popstate", () => { onPathChange() })
onPathChange()

/* required css for our application */
require('../tuto.webflow/css/tuto.webflow.css');