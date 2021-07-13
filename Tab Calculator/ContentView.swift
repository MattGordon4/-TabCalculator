//
//  This application was created as a tool for calculating what all of your friends owe you if you put your card down on the check or tab at a restaurant. It does this by taking down everyone's name and personal totals, then adding the tax and tip percentage evenly among everyone in the group and displaying what everyone owes to the cent.

//  ContentView.swift
//  Tab Calculator
//
//  Created by Matthew Gordon on 6/3/21.
//

import SwiftUI

/* Struct that represents the main menu or first thing you see when you open the app */
struct MenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                /* Background image */
                Image("RestaurantPhoto1").ignoresSafeArea()
                VStack {
                    /* Large TabCalculator Label */
                    Text("TabCalculator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 0)
                    
                    /* Navigation link to go from Menu to the ProportionalSplit view where the proportional calculations will be performed */
                    NavigationLink(
                        destination: ProportionalSplit(name: "", price: "", tip: "", foodTax: "", alcTax: "", tempAutoGrat: "", autoGrat: 0, earlyTabTotal: 0, finalTabTotal: 0, tempTipTotal: 0, tipTotal: 0, timesClicked: 0),
                        label: {
                            Text("Proportional Split").font(.largeTitle).foregroundColor(Color.white).padding().background(Color.black)
                        }).padding(.top, 100)
                    NavigationLink(
                        destination: EvenSplit(subTotal: "", tip: "", tempAutoGrat: "", autoGrat: 0, numberOfPeople: "", tempTip: 0, tipTotal: 0, total: 0, foodTax: "", alcTax: "", owe: 0, timesClicked: 0),
                        label: {
                            Text("Even Split").font(.largeTitle).foregroundColor(Color.white).padding().background(Color.black)                        })
                }
            }
        }
    }
}

/* Struct to represent the View of a Person object. Just calls the toString() method from the Person struct to get the formatted string */
struct PersonView: View {
    var person: Person
    
    var body: some View {
        Text(person.toString())
    }
}

/* Struct representing the ProportionalSplit page */
struct ProportionalSplit: View {
    /* Array of Person objects to represent the group of people */
    @State var people = [Person]()
    
    /* String representing the name the user inputs to create a Person */
    @State var name: String
    
    /* String representing the price the user inputs to create a Person */
    @State var price: String
   
    /* String representing the tip percentage the user inputs */
    @State var tip: String
    
    /* String representing the food tax the user inputs */
    @State var foodTax: String
    
    /* String representing the alcohol tax (if any) the user inputs */
    @State var alcTax: String
    
    /* String representing auto gratuity if the restuarant provides it */
    @State var tempAutoGrat: String
    
    /* Double representing the final auto gratuity value */
    @State var autoGrat: Double
    
    /* Temporary Double for the tab total before taxes to calculate tip */
    @State var earlyTabTotal: Double
   
    /* Double representing the total of the check/tab */
    @State var finalTabTotal: Double
    
    /* Temporary Double to hold tip total prior to rounding */
    @State var tempTipTotal: Double
    
    /* Double representing the tip total to write on the Tab */
    @State var tipTotal: Double
    
    /** Int to count how many times user has clicked the Calculate button to prevent multiple per reset */
    @State var timesClicked: Int
    
/* One large view for entering and displaying data */
    var body: some View {
        NavigationView {
            Form {
             /* Section for creating a Person object with user input areas for name and price */
                Section(header: Text("Add a Person and their subtotal")) {
                    HStack {
                        TextField("Enter name", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                        TextField("Enter \(name)'s total", text: $price).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    }
                   
                    /* Button that calls addPerson func passing in the user's input as parameters, it adds the created person to the people array and clears the text fields */
                    Button(action: {addPerson(newName: name, newPrice: price)}, label: {
                        Text("Add Person")
                    })
                }
                
                /* Section for displaying the people array in a list format that live updates for adding a Person to the array and doing calculations that change values */
                Section(header: Text("People (Final Calculations displayed here)")) {
                    List(people) { person in PersonView(person: person) }
                }
                
                /* Section for accepting user input for taxes and tip percentage */
                Section(header: Text("Add tax amount(s) and a tip percentage or provided auto-Gratuity Amount")) {
                    /* Food and Alcohol tax fields in an HStack to be side by side */
                    HStack {
                       
                        TextField("Food Tax", text: $foodTax).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        
                        TextField("Alcohol Tax", text: $alcTax).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    /* Tip perecentage and Auto-gratuity text fields in an HStack to be side by side */
                    HStack {
                        
                        TextField("Tip Percentage", text: $tip).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Auto-Gratuity", text: $tempAutoGrat).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    }
                    
                    /* Button to split the price of the check proportionally and show what everyone owes in the "People" list (more info in calculate() method itself). Also calls getFinalTotal() method which adds what everyone owes to get the final total */
                  
                    Button(action: {calculate()
                        finalCalculations()
                    }, label: {
                        Text("Calculate")      })
                    
                    /* Button to reset all of the data entered and restart */
                    Button(action: {reset()}, label: {
                            Text("Reset")               })
                    
                }
                
                /* Section to display the total of the entire tab when calculated */
                Section(header: Text("Tip and Total")) {
                    Text(tipAndTotalToString()).font(.largeTitle)
                    
                }
            
                /* Title for the entire NavigationView */
            }.navigationBarTitle("Proportional Split")
            
            
        }
    }
    
    /* func that takes user input from the MainPage, creates a Person object, and adds it to the people array */
    func addPerson(newName: String, newPrice: String) {
        /* guard to make sure the that the user actually inputted something, if not just clear the TextFields and return */
        guard newName.count > 0 && newPrice.count > 0 else {
            name = ""
            price = ""
            return
        }
        /* Rounding the user inputted price to two decimal places in case the user inputted a non-currency value */
        let roundedPrice: Double = roundMoney(total: (newPrice as NSString).doubleValue)
        let roundedPriceString: String = roundedPrice.description
        
        /* Creating a new person using the parameters */
        let newPerson: Person = Person(newName, roundedPriceString)
        
        /* Adding the Person created from the parameters to the people array */
        people.append(newPerson)
        
        /* Adding the newPerson's price to the earlyTabTotal (useful for getting tip later) */
        earlyTabTotal += (newPerson.getPrice() as NSString).doubleValue
        
        /* Clearing TextFields */
        name = ""
        price = ""
        
        
        
    }
    
    /* Func that does the proportional calculation to find out what everyone owes, by adding even taxes and tip to personal totals */
    func calculate() {
        /* Incrementing timesClicked */
        timesClicked += 1
        
        /* Guard to make sure user has not already calculated inputted data */
        guard timesClicked == 1 else {
            return
        }
        /* Temporary Person Array to store updated price values and eventually alias them to the people array */
        var tempArray = [Person]()
        
        /* Setting autoGrat to tempAutoGrat, this seemingly useless movement of variable assigments prevents the user from adding auto gratuity after they have already calculated once (breaking the original calculation) */
        autoGrat = (tempAutoGrat as NSString).doubleValue
        
        /* Calculation to find Food tax per person, Food tax total divided by the size of the people array */
        let foodTaxPer: Double = ((foodTax as NSString).doubleValue) / (Double(people.count))
        
        /* Calculation to find Alcohol tax per person, Alcohol tax divided by the size of the people array */
        let alcTaxPer: Double = ((alcTax as NSString).doubleValue) / (Double(people.count))
        
        /* Calculation to find auto gratuity per person if it was provided on the tab */
        let autoGratPer: Double = (autoGrat) / (Double(people.count))
        
        /* Calculation to find the tip percentage as a decimal (.00) */
        let tipAsPercent = (tip as NSString).doubleValue / 100
        
        /* Calculating temporary tip total (before rounding) */
        tempTipTotal = (earlyTabTotal * tipAsPercent)
        
        /* Rounding tip up to two decimal places as most people do round their tips to the nearest cent. Also makes math cleaner */
        tipTotal = roundUp(total: tempTipTotal)
        
        /* Calculating tip per person by dividing the tip total by the amount of people */
        let tipPer: Double = (tipTotal / (Double(people.count)))
         
        
        /* Storing money to add to each person (both taxes and tip) */
        let moneyToAdd: Double = (tipPer + foodTaxPer + alcTaxPer + autoGratPer)

        /* Loop through the people array to add the moneyToAdd to each Person's price */
        for person in people {
            /* Getting new total */
            let newTotal: String = ((person.getPrice() as NSString).doubleValue + moneyToAdd).description
            
            /* Creating new Person to represent the updated price (same name) */
            let updatedPerson: Person = Person(person.getName(), newTotal)
            
            /* Adding updated Person to the temporary array */
            tempArray.append(updatedPerson)
        }
       
        /* Removing everything from the people array (old values) */
        people.removeAll()
        
        /* Setting the people array to the tempArray which has the new values */
        people = tempArray
            
    }
    
    /* Func used to reset all inputted data and calculations with that data */
    func reset() {
        people.removeAll()
        foodTax = ""
        tip = ""
        alcTax = ""
        finalTabTotal = 0
        tempTipTotal = 0
        tipTotal = 0
        timesClicked = 0
        name = ""
        price = ""
        autoGrat = 0
        tempAutoGrat = ""
        earlyTabTotal = 0
        
    }
    
    /* Func to round the tip (Double) up to two decimal places (Money), takes in a Double as a parameter and returns the rounded Double. Does not use Schoolbook rounding, this func always rounds up if there are more than two decimal places  */
    func roundUp(total: Double) -> Double {
        let rounded: String = String(format: "%.2f", ceil(total * 100) / 100)
        return (rounded as NSString).doubleValue
    }
    
    /* Func to round money values to two decimal places. This func does use Schoolbook rounding */
    func roundMoney(total: Double) -> Double {
        let rounded: Double = round(total * 100) / 100.0
        return rounded
    }
    
    /* Func to round each person's final total as well as calculate the final total for the whole tab to display to the user */
    func finalCalculations() {
        /* Making sure this is the first time user is clicking calculate */
        guard timesClicked == 1 else {
            return
        }
        
        /* Temporary Person Array to hold changed values before being aliased to the main people array */
        var tempArray = [Person]()
        
        /* Loop to round up each person's new price calculated from the calculate() func to two decimal places. This rounding will sacrifice a few cents on to the total so that the total and what everyone owes adds up in two decimal form. Adding rounded prices to tempArray then making the people array equal to tempArray when the loop is over */
        for person in people {
            let rounded: Double = roundUp(total: (person.getPrice() as NSString).doubleValue)
            let roundedString: String = rounded.description
            tempArray.append(Person(person.getName(), roundedString))
        }
        people = tempArray
        
        /* Loop to calculate the finalTabTotal with each person's final total added together */
        for person in people {
            finalTabTotal += (person.getPrice() as NSString).doubleValue
        }
    }
   
    /* Func to obtain a formatted String with the Tip and Total to display on the screen for the user */
    func tipAndTotalToString() -> String {
        /* Making sure total is in two decimal place format */
        let roundedTotal: Double = roundMoney(total: finalTabTotal)
        /* Combing auto grat and tip to display either since one should be zero or the group is doing extra tip */
        let gratAndTip: Double = autoGrat + tipTotal
        /* Returning formatted String */
        return "Tip: $" + gratAndTip.description + "\n" + "Total: $" +    roundedTotal.description
    }

}

/* View for the even split page */
struct EvenSplit: View {
    /* User's input for the subtotal of the check */
    @State var subTotal: String
    
    /* User's input for tip percentage */
    @State var tip: String
    
    /* User's input for auto gratuity */
    @State var tempAutoGrat: String
    
    /* Double to hold the final auto gratuity value */
    @State var autoGrat: Double
    
    /* User's input for the number of people */
    @State var numberOfPeople: String
    
    /* Double to hold tip value before rounding */
    @State var tempTip: Double
    
    /* Double to hold the total tip for the tab */
    @State var tipTotal: Double
    
    /* Double to hold the final total tab price value */
    @State var total: Double
    
    /* User's input for food tax */
    @State var foodTax: String
    
    /* User's input for alcohol tax */
    @State var alcTax: String
    
    /* Double to hold the "what everyone owes" value */
    @State var owe: Double
    
    /* Int to keep track of how many times "calculate" button was pressed so never more than once */
    @State var timesClicked: Int
    
    /* Actual view for data input and calculation for even split */
    var body: some View {
        NavigationView {
            Form {
                /* Section to add subtotal */
                Section(header: Text("Add Subtotal")) {
                    TextField("Enter Subtotal", text: $subTotal).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                
                }
                /* Section to add rest of input and "calculate" or "reset" */
                Section(header: Text("Add Info where applicable (0 if not)")) {
                    /* HStack to have food tax and alcohol tax input next to each other */
                    HStack {
                        TextField("Food Tax", text: $foodTax).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Alcohol Tax", text: $alcTax).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    /* HStack to have tip percentage and auto gratuity input next to each other */
                    HStack {
                        TextField("Tip Percentage", text: $tip).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Auto Gratuity", text: $tempAutoGrat).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
        
                    /* Isolated text field to input the number of people to split the tab between */
                    TextField("Number of people", text: $numberOfPeople).keyboardType(.decimalPad).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    /* Button to do the even split calculation (more info in calculate() method) */
                    Button(action: {calculate()}, label: {
                        Text("Calculate")
                    })
                    
                    /* Button to reset the input and calculations */
                    Button(action: {reset()}, label: {
                        Text("Reset")
                    })
                    
                }
                
                /* Section to display output from calculations */
                Section {
                    Text(infoToString()).font(.largeTitle)
                }
            }
        }.navigationTitle("Even Split")
    }
    
    /* Func for even split calculation */
    func calculate() {
        /* Incrementing timesClicked */
        timesClicked += 1
        
        /* Guard to make sure user has not already calculated inputted data */
        guard timesClicked == 1 else {
            return
        }
        
        /* Guard to make sure user inputted a number of people, if they did not the calculations will break, also resets the times clicked in case user want to add number of people value and try again*/
        guard numberOfPeople.count != 0 else {
            timesClicked = 0
            return
        }
        
        /* Calculation to find the tip as a decimal (.00) for percentage arithmetic */
        let tipAsDecimal: Double = (tip as NSString).doubleValue / 100
        
        /* Setting tempTip to the subtotal times the tip as a decimal */
        tempTip = (subTotal as NSString).doubleValue * tipAsDecimal
        /* Setting the tipTotal to the rounded up tempTip (same explanation as in ProportionalSplit) */
        tipTotal = roundUp(total: tempTip)
        
        /* Setting autoGrat to tempAutoGrat, this seemingly useless movement of variable assigments prevents the user from adding auto gratuity after they have already calculated once (breaking the original calculation) */
        autoGrat = (tempAutoGrat as NSString).doubleValue
        
        /* Adding all values to get the total used to calculate what everyone owes */
        total += (subTotal as NSString).doubleValue
        total += tipTotal
        total += (tempAutoGrat as NSString).doubleValue
        total += (foodTax as NSString).doubleValue
        total += (alcTax as NSString).doubleValue
        
        /* Calculating what everyone owes by dividing the number of people by the total and rounding it up to stay within currency's two decimal places */
        owe = roundUp(total: (total / (numberOfPeople as NSString).doubleValue))
        
    }
    
    /* Func to round a double up to two decimal places (always rounds up) */
    func roundUp(total: Double) -> Double {
        let rounded: String = String(format: "%.2f", ceil(total * 100) / 100)
        return (rounded as NSString).doubleValue
    }
    
    /* Func to round a double to two decimal places (not always up, can drop down) */
    func roundMoney(total: Double) -> Double {
        let rounded: Double = round(total * 100) / 100.0
        return rounded
    }
    
    /* Func to reset inputted data and calcutions by clearing all variables */
    func reset() {
        timesClicked = 0
        subTotal = ""
        tip = ""
        tempAutoGrat = ""
        autoGrat = 0
        numberOfPeople = ""
        tempTip = 0
        tipTotal = 0
        total = 0
        foodTax = ""
        alcTax = ""
        owe = 0
     
    }
    
    /* Func to generate a string for displaying calculation output */
    func infoToString() -> String {
        /* Double to represent tip percent and auto gratuity to account for which the user chooses (could be both with extra tip) */
        let gratAndTip: Double = tipTotal + autoGrat
        
        /* String format for tip (Tip: $10.55) */
        let tipToString: String = "Tip: $" + gratAndTip.description
        
        /* String format for the total (Total: $122.87). To get a total where all the math works out in currency form, there needs to be a compromise, so to get the total, I multiplied what everyone owes by the number of people. This slight rounding sacrifices complete accuracy to have equal currency values for everyone (a few cents off depending on the amount of people) */
        let totalToString: String = "Total: $" + (owe * (numberOfPeople as NSString).doubleValue).description
        
        /* String format for what everyone owes (Per Person: $8.95) */
        let oweToString: String = "Per Person: $" + owe.description
        
        /* Returning the three strings on separate lines for organized display */
        return tipToString + "\n" + totalToString + "\n" + oweToString
    }
    
}


    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MenuView()
            MenuView()
        }
    }
}

