class Personas{

// DATOS 
  var formasDePago = []
  var formaDePagoPreferida

  var cosasCompradas = []
  var property salarioMensual
  const cuotasPagar = []
  const cuotasVencidas = []
  var mesActual

// SALDO DE LA PERSONA EN DIFERENTES CUENTAS

  var property plata
  var property plataCuentaBancaria

// METODOS NECESARIOS

  method mesActual() = mesActual

  method ganar(cantidad) {
    plata += cantidad
  }

  method gastar(cantidad){
    plata -= cantidad
  }

  method pagarCuota(){
    self.gastar(cuotasPagar.head())
  }

  method agregarCuotasParaPagar(cuota){
    cuotasPagar.add(cuota)
  }

// PUNTO 1 PROCESO DE COMPRA

  method puedeComprar(monto) = formaDePagoPreferida.cubreCosto(self,monto)

  method comprar(monto,cosaParaComprar){
    if(self.puedeComprar(monto)){
      cosasCompradas.add(cosaParaComprar)
      formaDePagoPreferida.comprar(self,monto)
    }
  }

// PUNTO 2 CAMBIAR FORMA DE PAGO PREFERIDA

  method cambiarFormaDePagoPreferida(){
    formaDePagoPreferida = formasDePago.anyOne()
  }

// PUNTO 3 LAS PERSONAS COBRAN Y PAGAN

  method transcurrir(){
    var salarioNuevo = self.salarioMensual()

    mesActual += 1
    cuotasPagar.forEach{
      cuota => 
      if(not(self.puedoPagarCon(salarioNuevo,cuota))){
          self.agregarCuotaVencida(cuota)
        }
      else{
        self.puedoPagarCon(salarioNuevo,cuota)
        salarioNuevo -= cuota
        }
    }
    self.ganar(salarioNuevo)
  }

  method puedoPagarCon(cantidad,cuota) = cantidad > cuota

  method agregarCuotaVencida(cuota){
    cuotasVencidas.add(cuota)
  }

  // PUNTO 4

  method montoCuotasSinPagar() = cuotasVencidas.sum()

  // PUNTO 5
}

class MetodosDePago{
  method cubreCosto(persona,monto) = persona.plata() >= monto
}

object efectivo inherits MetodosDePago{
  method comprar(persona,monto){
    if(persona.plata() >= monto)
      persona.gastar(monto)
  }
}

class Debito inherits MetodosDePago{
  override method cubreCosto(persona,monto) = persona.plataCuentaBancaria() >= monto

  method comprar(persona,monto){
    if(self.cubreCosto(persona,monto))
      persona.gastar(monto)
  }
}

class Credito inherits MetodosDePago{
  const bancoEmisor
  override method cubreCosto(persona,monto) = monto <= bancoEmisor.montoMaximo()

  var mesDeCompra

  method comprar(persona,monto){
    (bancoEmisor.cantidadCuotas()).times(persona.agregarCuotasParaPagar(monto/(bancoEmisor.cantidadCuotas())*bancoEmisor.tasaDeInteres()))
    mesDeCompra = persona.mesActual()
  }
}

class bancoEmisor {
  const property montoMaximo
  var property cantidadCuotas
  const property tasaDeInteres
}

// SEGUNDA PARTE



// HACER 2 TESTS UNO DE UNA COMPRA EN CUOTAS Y OTRO DE COBRAR SUELDOS