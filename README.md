Riemann Sum: UIAccessibility Demo
==========================================

The application allows the user to model one of 3 functions in a graph and select the number of rects to approximate the integral using a Riemann Sum. (This demo uses the Left Riemann Sum.)

This app has been made fully accessible to demonstrate the use of Apple's UIAccessibility protocols / classes. It demonstrates basic accessibility additions via customization of accessibilityLabel properties thru more advanced accessibility via custom accessibility containers. It also demonstrates a workaround for a known iOS accessibility issue where UISegmentedControl does not respect accessibilityLabel property settings on the NSStrings provided to the control. 

### Screenshot

![Riemann Sum screenshot](https://raw.github.com/spanage/riemann_sum_ax_ios/master/screenshot.png)