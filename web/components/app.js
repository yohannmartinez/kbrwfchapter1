
var ReactDOM = require('react-dom')
var React = require("react")
var Qs = require('qs')
var Cookie = require('cookie')
var localhost = require('reaxt/config').localhost
var When = require('when')
var XMLHttpRequest = require("xhr2")
var createReactClass = require('create-react-class')

require('../tuto.webflow/css/tuto.webflow.css');

var browserState = {}

var HTTP = new (function () {
  this.get = (url) => this.req('GET', url)
  this.delete = (url) => this.req('DELETE', url)
  this.post = (url, data) => this.req('POST', url, data)
  this.put = (url, data) => this.req('PUT', url, data)

  this.req = (method, url, data) => new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    url = (typeof window !== 'undefined') ? url : localhost + url
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

var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && { handlerPath: [Layout, Header, Orders] }
    }
  },
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path)
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

var Child = createReactClass({
  render() {
    var [ChildHandler, ...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
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

    return <JSXZ in="orders" sel=".layout">
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

    for (let i = 0; i < Math.ceil(array / showedNumber); i++) {
      range.push(i + 1);
    }

    return range
  },
  render() {
    let range = this.range(this.props.orders.value.response.numFound, Number(this.props.qs.rows))
    return <JSXZ in="orders" sel=".div-global-button">
      <Z sel=".pages-container">
        {range.map((page, index) => (
          <div className="page-number" style={{ color: Number(this.props.qs.page) === index ? "red" : "black" }} onClick={() => { this.props.Link.GoTo("orders", "", { page: String(index), rows: this.props.qs.rows, sort: this.props.qs.sort }) }}>{page}</div>
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
            <Z sel=".table-col5" onClick={() => { this.props.Link.GoTo("order", order._yz_rk) }}>{"->"}</Z>
            <Z sel=".table-col6" onClick={()=>{ HTTP.post("/api/order/pay", order).then((res)=>{console.log(res)})}}>pay</Z>
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
          <Z sel=".address">address: {this.props.order.value.custom.billing_address.city}</Z>
          <Z sel=".command-number">command number: {this.props.order.value.remoteid}</Z>
        </JSXZ>

      </Z>
    </JSXZ>
  }
})

var ErrorPage = createReactClass({
  render() {
      return <h1>{this.props.code + " " + this.props.message}</h1>
  }
})

var Link = createReactClass({
  statics: {
      renderFunc: null, //render function to use (differently set depending if we are server sided or client sided)
      GoTo(route, params, query) {// function used to change the path of our browser
          var path = routes[route].path(params)
          var qs = Qs.stringify(query)
          var url = path + (qs == '' ? '' : '?' + qs)
          history.pushState({}, "", url)
          Link.onPathChange()
      },
      onPathChange() { //Updated onPathChange
          var path = location.pathname
          var qs = Qs.parse(location.search.slice(1))
          var cookies = Cookie.parse(document.cookie)
          inferPropsChange(path, qs, cookies).then( //inferPropsChange download the new props if the url query changed as done previously
              () => {
                  Link.renderFunc(<Child {...browserState} />) //if we are on server side we render 
              }, ({ http_code }) => {
                  Link.renderFunc(<ErrorPage message={"Not Found"} code={http_code} />, http_code) //idem
              }
          )
      },
      LinkTo: (route, params, query) => {
          var qs = Qs.stringify(query)
          return routes[route].path(params) + ((qs == '') ? '' : ('?' + qs))
      }
  },
  onClick(ev) {
      ev.preventDefault();
      Link.GoTo(this.props.to, this.props.params, this.props.query);
  },
  render() {//render a <Link> this way transform link into href path which allows on browser without javascript to work perfectly on the website
      return (
          <a href={Link.LinkTo(this.props.to, this.props.params, this.props.query)} onClick={this.onClick}>
              {this.props.children}
          </a>
      )
  }
})

function inferPropsChange(path, query, cookies) { // the second part of the onPathChange function have been moved here
  browserState = {
      ...browserState,
      path: path, qs: query,
      Link: Link,
      Child: Child
  }

  var route, routeProps
  for (var key in routes) {
      routeProps = routes[key].match(path, query)
      if (routeProps) {
          route = key
          break
      }
  }

  if (!route) {
      return new Promise((res, reject) => reject({ http_code: 404 }))
  }
  browserState = {
      ...browserState,
      ...routeProps,
      route: route
  }

  return addRemoteProps(browserState).then(
      (props) => {
          browserState = props
      })
}

module.exports = {
  reaxt_server_render(params, render) {
      inferPropsChange(params.path, params.query, params.cookies)
          .then(() => {
              render(<Child {...browserState} />)
          }, (err) => {
              render(<ErrorPage message={"Not Found :" + err.url} code={err.http_code} />, err.http_code)
          })
  },
  reaxt_client_render(initialProps, render) {
      browserState = initialProps
      Link.renderFunc = render
      window.addEventListener("popstate", () => { Link.onPathChange() })
      Link.onPathChange()
  }
}

/* required css for our application */