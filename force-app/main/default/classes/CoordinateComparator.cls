public class CoordinateComparator implements Comparator<MZ_Coordinate__c> {
    public Integer compare(MZ_Coordinate__c c1, MZ_Coordinate__c c2) {
     	Integer returnValue = 0;
        if(c1 == null && c2 == null) {
            returnValue = 0;
        } else if(c1 == null) {
            returnValue = 1;
        } else if(c2 == null) {
            returnValue = -1;
        } else if(c1.MZ_CoordinateScore__c > c2.MZ_CoordinateScore__c) {
            returnValue = -1;
        } else if(c1.MZ_CoordinateScore__c < c2.MZ_CoordinateScore__c) {
        	returnValue = 1;
        }
        return returnValue;
    }
}