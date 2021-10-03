
LIST parties = (Johannesland), (Ivanovia), USA

LIST host_city = Johannesstadt, Ivangrad, Geneva



INCLUDE issues.ink


-> prologue

=== prologue ===

It is the year 2032.  The international order is deteriorating.  After years of tention, the nation of Johannesland has just invaded the Valego Valley, a disputed region previously under the <i>de facto</i> control of Ivanovia. 
After many casualties, the belligerent nations have agreed to a tentative ceasefire and negotiations mediated by the UN.  Both bring a long laundry list of complaints to the table.
As a high-ranking officer of the UN, you have been placed in charge of resolving this conflict before it escalates into a world war. If necessary, you have the ability to deploy troops.

But first things first: Where will you hold the negotiations?

 * [Johannesstadt, capital of Johannesland]
    ~host_city = (Johannesstadt)
 * [Ivangrad, capital of Ivanovia]
    ~host_city = (Ivangrad)
 * [Geneva, Switzerland]
    ~host_city = (Geneva)
 -
 
The negotiations begin in a highly secured conference room in {LIST_MIN(host_city)}. <>
{host_city !? Geneva: The representative from {host_city ? Johannesstadt: Johannesland | Ivanovia} enters confidently with his retinue. The representative from {host_city ? Johannesstadt: Ivanovia | Johannesland} arrives flanked by bodyguards, clearly indignant at the bias implied by your choice of location. | Representatives from Johannesland and Ivanovia enter with their respective retinues.}
  * [Let's get started...]
  - -> address_issues

-> END