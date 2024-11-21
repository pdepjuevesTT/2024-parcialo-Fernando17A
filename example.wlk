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

  method transcurrirMes(){
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

  method verificarEstadoCrediticio() = cuotasVencidas.size() == 0
}

class NuevoCredito inherits Credito{

  // EL ESTADO CREDITICIO ES true EN CASO DE QUE LA PERSONA NO TENGA CUOTAS VENCIDAS,
  // SI TIENE CUOTAS VENCIDAS ENTONCES DEBE SER false, QUIEN TENGA ESTADO CREDITICIO MALO (false)
  // NO PUEDE REALIZAR COMPRAS CON CREDITO, ADEMAS DEBE CUMPLIR CON EL REQUISITO DE QUE EL MONTO DE
  // LA COMPRA NO DEBE SUPERAR EN MONTO MAXIMO QUE PERMITE EL BANCO

  override method cubreCosto(persona,monto) = (monto <= bancoEmisor.montoMaximo()) && persona.verificarEstadoCrediticio()
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

class CompradoresCompulsivos inherits Personas{

  override method comprar(monto,cosaParaComprar){
    if(self.puedeComprar(monto)){
      cosasCompradas.add(cosaParaComprar)
      formaDePagoPreferida.comprar(self,monto)
    }
    else
      if(self.otroMetodoPuedePagar(monto))
        self.cambiarFormaDePagoPreferida(formasDePago.any{formaDePago => formaDePago.cubreCosto(self, monto)})
        self.comprar(monto,cosaParaComprar)
  }
  
  method cambiarFormaDePagoPreferida(nueva){
    formaDePagoPreferida = nueva
  }

  override method puedeComprar(monto) = formaDePagoPreferida.cubreCosto(self,monto)

  method otroMetodoPuedePagar(monto) = formasDePago.any{formaDePago => formaDePago.cubreCosto(self, monto)}
}

class PagadoresCompulsivos inherits Personas{

  override method transcurrirMes(){
    super()
    if(self.puedoPagarConEfectivo()){
      cuotasVencidas.removeAllSuchThat{ cuota =>
        self.puedoPagarCon(plata,cuota)
        plata -= cuota
      }
    }

  }

  method puedoPagarConEfectivo() = plata >= cuotasVencidas.head()
}
// HACER 2 TESTS UNO DE UNA COMPRA EN CUOTAS Y OTRO DE COBRAR SUELDOS